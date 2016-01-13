class BusinessesController < ApplicationController
  before_action :signed_in_user, only: [:edit, :destroy]
  before_action :signed_in_admin, only: [:admin_index]
  helper_method :sort_column, :sort_direction

  STATUS_FLAGS = { "In Use" => "full",
                   "Not In Use" => "not-in-use" }

  SOURCE_FLAGS = { "User Submitted" => "user",
                   "State Corporate DB" => "state-corp",
                   "State Trademark DB" => "state-tm",
                   "Federal Trademark DB" => "federal-tm" }

  def index
    @businesses = Business.filtered_search(params[:search],params[:state_id],params[:source])
    @states = State.select(:id, :state).distinct.where("state is not null").order(:state)
    @sources = Source.select(:id,:source)
    #Business.joins("join sources on sources.id = businesses.source_id").select("businesses.source_id,businesses.source").distinct


    if (params[:search].blank? and params[:state_id].blank? and params[:source_id].blank?)

      count=1000
      #count = Rails.cache.fetch('biz_count') {
      #  Business.count
      #}
    else
      count = @businesses.count
    end

    @not_first = request.query_string.present?
    @businesses = @businesses.paginate(:page => params[:page], :per_page => 30, :total_entries => count)
    #.order(sort_column + " " + sort_direction).includes(:name_object)
    respond_to do |format|
      format.js
      format.html
    end
  end

  def admin_index
    @businesses = Business.search_user_submitted_by_name(params[:search])
                          .order(sort_column + " " + sort_direction)
                          .paginate(:page => params[:page], :per_page => 30)

    render "businesses/index"
  end

  def show
    @business = Business.find(params[:id])
    if @business.source == "user"
      @status = STATUS_FLAGS.key(@business.status)
    else
      @status = SOURCE_FLAGS.key(@business.source)
    end
    @products = @business.products
  end

  def new
    @is_new = true
    @business = Business.new
    @business.name_object = @business.build_name_object
    unless params[:new_name].blank?
      @business.name_object.name = params[:new_name] 
    end
    if signed_in?
      @user = @business.name_object.user = current_user
    else
      @user = @business.name_object.user = @business.name_object.build_user
    end
    @sic_codes = populate_sic_codes
    @entity_types = populate_entity_types
    @state_abbreviations = populate_state_abbreviations
    if params[:price_tier]
      @default_price = PriceTier.find params[:price_tier]
    else
      @default_price = PriceTier.find_by machine_label: 'annual'
    end
    @price_tiers = PriceTier.where(is_renewal: false).order(price: :asc)
  end

  def create
    @business = Business.new(business_params)
    logger.debug "New business: #{@business.attributes.inspect}"

    if signed_in?
      @business.name_object.user = current_user
    else
      #make new user from form
      #validate new user info
      #TODO: test submission
    end
    @business.source = "user"

    #clean out leading blank from operating_region input
    @business.operating_region.reject!( &:blank? )

    #set status
    if not @business.in_use?
      @business.status = "not-in-use"
    elsif @business.proof_of_use_filename.blank?
      @business.status = "no-proof"
    else
      @business.status = "full"
    end

    price_tier = PriceTier.find params[:business][:price_tier]

    # Create the charge on Stripe's servers - this will charge the user's card
    amount = price_tier.price
    coupon = nil
    unless params[:coupon_code].blank?
      coupon = Coupon.find_by code: params[:coupon_code]
      logger.debug coupon.description
      unless coupon.expired?
        amount = coupon.final_price amount
        logger.debug "Amount: " + amount.to_s
      end
    end
		token = params[:stripeToken]
    t = Transaction.new
    begin
			Stripe.api_key = Rails.application.secrets.stripe_api_key
      if amount > 0
        charge = Stripe::Charge.create(
          amount: amount, # amount in cents, again
          currency: "usd",
          card: token,
          description: "Business registration for " + @business.name_object.name,
        )
        t.charge_id = charge.id
      else
        t.charge_id = "free"
        amount = 0
      end
      t.price_tier = price_tier
      t.amount = amount
      t.coupon = coupon
      coupon.number_of_uses = coupon.number_of_uses - 1
      t.user = @business.name_object.user
      t.name_object = @business.name_object
    rescue Stripe::CardError => e
      # The card has been declined
      flash.now[:warning] = "The card has been declined"
      paid = false
    else
      @business.price_tier = price_tier
      paid = true
      @business.payment_expire = price_tier.months_to_expire.months.from_now
    end

    if paid and @business.save
      t.save
      flash.now[:success] = "Name has been registered"

      #upload proof of use
      if @business.in_use
        proof = params[:business][:proof_of_use_file]
        if not proof.nil?
          @business.proof_of_use_filename = save_proof_file(proof, @business).to_s
          @business.status = "full"
          @business.save
        end
      end

      #upload image
      image = params[:business][:image_file]
      if not image.nil?
        @business.full_image_filename = save_image_file(image, @business).to_s
        @business.save
      end

      @business.send_user_email
      UserMailer.biz_notification(@business).deliver unless Rails.env.development?
      respond_to do |format|
        format.html {
          if @business.source == "user"
            @status = STATUS_FLAGS.key(@business.status)
          else
            @status = SOURCE_FLAGS.key(@business.source)
          end
          render 'show'
        }
        format.json { render json: @business, status: :created }
        format.js {}
      end
    else
      @sic_codes = populate_sic_codes
      @entity_types = populate_entity_types
      @state_abbreviations = populate_state_abbreviations
      @price_tiers = PriceTier.where(is_renewal: false)
      @default_price = (price_tier.nil? ? @price_tiers.first : price_tier)
      @is_new = true
      render 'new'
    end
  end

  def edit
    @is_new = true
    @user = current_user
    @sic_codes = populate_sic_codes
    @entity_types = populate_entity_types
    @state_abbreviations = populate_state_abbreviations
    if current_user.is_an_admin?
      @status_flags = STATUS_FLAGS
      @source_flags = SOURCE_FLAGS
    end

    @business = Business.find_by_id(params[:id])
    if @business.name_object.user.id != current_user.id and not current_user.is_an_admin?
      flash[:danger] = "Not able to edit this object"
      redirect_to business_path(@business)
    end
    @price_tiers = PriceTier.all
    @default_price = (@business.price_tier.nil? ? PriceTier.find_by(machine_label: 'lifetime') : @business.price_tier)
    @business.date_of_first_use = @business.date_for_editing("date_of_first_use")
    @business.planned_date = @business.date_for_editing("planned_date")
  end

  def update
    @business = Business.find_by_id(params[:id])
    if @business.name_object.user != current_user and not current_user.is_an_admin?
      flash[:danger] = "Not able to edit this object"
      redirect_to business_path(@business)
    end

    @business.update(edit_business_params)

    #upload proof of use
    proof = params[:business][:proof_of_use_file]
    @business.proof_of_use_filename = save_proof_file(proof, @business).to_s unless proof.nil?

    #upload image
    image = params[:business][:image_file]
    @business.full_image_filename = save_image_file(image, @business).to_s unless image.nil?

    #set status
    if not current_user.is_an_admin? #if not set in form
      if not @business.in_use?
        @business.status = "not-in-use"
      elsif @business.proof_of_use_filename.blank?
        @business.status = "no-proof"
      else
        @business.status = "full"
      end
    end

    if @business.save
      flash[:success] = "Business has been updated"
      redirect_to @business
    else
      @sic_codes = populate_sic_codes
      @entity_types = populate_entity_types
      @state_abbreviations = populate_state_abbreviations
      render 'edit'
    end
  end

  def renew
    @user = current_user
    @business = Business.find_by_id(params[:id])
    if @business.name_object.user.id != current_user.id and not current_user.is_an_admin?
      flash[:danger] = "Not able to edit this object"
      redirect_to business_path(@business)
    end
    #Politely decline renewal on lifetime registrations
    if not @business.price_tier.nil? and (@business.price_tier.machine_label == 'lifetime' or @business.price_tier.machine_label == 'life_renewal')
      flash[:warning] = "This registration is already good for life"
      redirect_to business_path(@business)
    end
    @price_tiers = PriceTier.where(is_renewal: true).order(price: :asc)
    @default_price = PriceTier.find_by(machine_label: 'half_renewal')
  end

  def update_expiration
    @business = Business.find_by_id(params[:business][:id])
    if @business.name_object.user != current_user and not current_user.is_an_admin?
      flash[:danger] = "Not able to edit this object"
      redirect_to business_path(@business)
    end

    price_tier = PriceTier.find params[:business][:price_tier]
    # Create the charge on Stripe's servers - this will charge the user's card
    amount = price_tier.price
    coupon = nil
    unless params[:coupon_code].blank?
      coupon = Coupon.find_by code: params[:coupon_code]
      logger.debug coupon.description
      unless coupon.expired?
        amount = coupon.final_price amount
        logger.debug "Amount: " + amount.to_s
      end
    end
		token = params[:stripeToken]
    t = Transaction.new
    begin
			Stripe.api_key = Rails.application.secrets.stripe_api_key
      if amount > 0
        charge = Stripe::Charge.create(
          amount: amount, # amount in cents, again
          currency: "usd",
          card: token,
          description: "Business registration for " + @business.name_object.name,
        )
        t.charge_id = charge.id
      else
        t.charge_id = "free"
        amount = 0
      end
      t.price_tier = price_tier
      t.amount = amount
      t.coupon = coupon
      t.user = @business.name_object.user
      t.name_object = @business.name_object
    rescue Stripe::CardError => e
      # The card has been declined
      flash.now[:warning] = "The card has been declined"
    else
      @business.price_tier = price_tier
      @business.payment_expire = @business.payment_expire + price_tier.months_to_expire.months
      @business.save
      t.save
      flash[:success] = "You have successfully extended your registration"
    end

    redirect_to @business
  end

  def destroy
    @business = Business.find_by_id(params[:id])
    if @business.name_object.user != current_user and not current_user.is_an_admin?
      flash[:danger] = "Not able to delete this object"
      redirect_to business_path(@business)
    end

    if @business.destroy
      flash[:success] = "Business was successfully deleted."
    else
      flash[:danger] = "Something went wrong"
    end

    redirect_to :back
  end

  def proof
    business = Business.find_by_id(params[:id])
    logger.debug business.proof_of_use_filename
    send_file business.proof_of_use_filename, disposition: 'inline'
  end

  def full_image
    business = Business.find_by_id(params[:id])
    send_file business.full_image_filename, disposition: 'attachment'
  end

  def upgrade
    @user = current_user

    # Get the credit card details submitted by the form
    token = params[:stripeToken]
  end

  #JSON Endpoints
  def page_errors
  #TODO FIX PROOF OF USE
    fields_by_page = [
              [:sic_code, :entity_type, :tagline, :address1, :address2, :city, :state, :zip_code, :phone],       #first form page
              [:website, :image_file, :in_use, :plans_for_use, :planned_date, :date_of_first_use, :is_interstate, :operating_region, :proof_of_use_file],
              []
             ]
    fields_by_page[1] = fields_by_page[0] + fields_by_page[1]  #can validate cumulatively
    #build model
    business = Business.new(business_params)
    #get set of fields to validate
    form_page = params[:form_page].to_i
    fields_to_validate = fields_by_page[form_page - 1] #page numbers have 1-based index
    logger.debug fields_to_validate.to_s
    errors = business.partial_errors(fields_to_validate)
    if params[:business][:name_object][:name].blank?
      errors.add(:name_object_name, "can't be blank")
    end
    if fields_to_validate.include? :proof_of_use_file and business.in_use and params[:business][:proof_of_use_file].blank?
      errors.add(:proof_of_use_file, "can't be blank")
    end
    render json: { errors: errors }
  end

  private
    def populate_sic_codes
      Rails.cache.fetch('sic_code_list') {
        f = File.open("data/sic_codes.json")
        sic_code_list = JSON.parse f.read()
        f.close()
        sic_code_list
      }
    end

    def populate_entity_types
      Rails.cache.fetch('entity_types_list') {
        f = File.open("data/entity_types.json")
        entity_type_list = JSON.parse f.read()
        f.close()
        entity_type_list
      }
    end

    def populate_state_abbreviations
      Rails.cache.fetch('state_abbreviations_list') {
        f = File.open("data/state_abbreviations.json")
        state_abbreviations_list = JSON.parse f.read()
        f.close()
        state_abbreviations_list
      }
    end

    def sort_column
      permissible = Business.column_names.clone.map { |name| Business.table_name + "." + name }
      n = NameObject.column_names.clone.map { |name| NameObject.table_name + "." + name}
      permissible.concat(n)
      permissible.include?(params[:sort]) ? params[:sort] : "name_objects.name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def business_params
      calc_date_mask('planned_date')
      calc_date_mask('date_of_first_use')
      biz = params.required(:business)
                  .permit(:tagline,
                          :address1,
                          :address2,
                          :city,
                          :state_id,
                          :source_id,
                          :zip_code,
                          :sic_code,
                          :website,
                          :entity_type,
                          :phone,
                          :in_use,
                          :date_of_first_use,
                          :date_of_first_use_mask,
                          :plans_for_use,
                          :planned_date,
                          :planned_date_mask,
                          :is_interstate,
                          :status,
                          :source,
                          {operating_region: []},
                          {name_object: [ :name ,
                                          :id,
                                          {user: [:name,
                                                  :username,
                                                  :email,
                                                  :password,
                                                  :password_confirmation]}]})
      biz[:name_object_attributes] = biz.delete(:name_object)
      biz[:name_object_attributes][:user_attributes] = biz[:name_object_attributes].delete(:user) if biz[:name_object_attributes].has_key? :user
      logger.debug "#{biz.inspect}"
      return biz
    end

    def edit_business_params
      calc_date_mask('planned_date')
      calc_date_mask('date_of_first_use')
      biz = params.required(:business)
                  .permit(:tagline,
                          :sic_code,
                          :address1,
                          :address2,
                          :city,
                          :state_id,
                          :zip_code,
                          :website,
                          :entity_type,
                          :phone,
                          :in_use,
                          :date_of_first_use,
                          :date_of_first_use_mask,
                          :plans_for_use,
                          :planned_date,
                          :planned_date_mask,
                          :is_interstate,
                          :status,
                          :source,
                          {operating_region: []},
                          {name_object: [ :name ,
                                          :id,
                                          {user: [:name,
                                                  :username,
                                                  :email,
                                                  :password,
                                                  :password_confirmation]}]})
      if admin?
        biz[:name_object_attributes] = biz.delete(:name_object)
        biz[:name_object_attributes][:user_attributes] = biz[:name_object_attributes].delete(:user) if biz[:name_object_attributes].has_key? :user
      else
        biz.delete(:state_id)
        biz.delete(:name_object)
        biz.delete(:sic_code)
      end
      logger.debug "#{biz.inspect}"
      return biz
    end

    def signed_in_user
      if not signed_in?
        flash[:danger] = "Please sign in"
        redirect_to signin_url
      end
    end

    def save_proof_file(file, business)
      filename = Rails.root.join('data', 'uploads', business.name_object.user.id.to_s,
                                 business.id.to_s, 'proof' + File.extname(file.original_filename))
      FileUtils.mkdir_p(File.dirname(filename)) unless File.directory?(File.dirname(filename))
      File.open(filename, 'wb') do |target|
        target.write(file.read)
      end
      return filename
    end

    def save_image_file(file, business)
      filename = Rails.root.join('data', 'uploads', business.name_object.user.id.to_s,
                                 business.id.to_s, 'full_image' + File.extname(file.original_filename))
      FileUtils.mkdir_p(File.dirname(filename)) unless File.directory?(File.dirname(filename))
      File.open(filename, 'wb') do |target|
        target.write(file.read)
      end
      return filename
    end

    #run before params get used to create business
    def calc_date_mask(field_name)
      if params[:business][:"#{field_name}(2i)"] == '' and params[:business][:"#{field_name}(3i)"] != ''
        return
      elsif params[:business][:"#{field_name}(2i)"] == ''
        params[:business][:"#{field_name}(2i)"] = '1'
        params[:business][:"#{field_name}(3i)"] = '1'
        params[:business][:"#{field_name}_mask"] = :year
      elsif params[:business][:"#{field_name}(3i)"] == ''
        params[:business][:"#{field_name}(3i)"] = '1'
        params[:business][:"#{field_name}_mask"] = :year_month
      else
        params[:business][:"#{field_name}_mask"] = :year_month_day
      end
    end
end
