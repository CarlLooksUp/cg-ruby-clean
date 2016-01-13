class ProductsController < ApplicationController
  before_action :signed_in_user, only: [:new, :edit, :destroy]
  helper_method :sort_column, :sort_direction

  autocomplete :product_type, :label, full: true
  autocomplete :name_object, :name, full: true, scopes: [:businesses]

  def index
    @products = Product.all
    @products = @products.order(sort_column + " " + sort_direction).includes(:name_object).paginate(page: params[:page], per_page: 30, total_entries: @products.count)
  end

  def new
    if current_user.cart.nil?
      current_user.cart = Cart.create
    end
    @is_new = true
    @product = Product.new
    @product.name_object = @product.build_name_object
    @goods = ProductType.find_by(label: "Goods").children.order(:label)
    @services = ProductType.find_by(label: "Services").children.order(:label)
  end

  def add_and_continue
    if current_user.cart.nil?
      current_user.cart = Cart.create
    end
    product = build_product_from_params
    unless product.errors.messages.empty?
      logger.debug product.errors.inspect
      if product.errors.messages.has_key? :"name_object.name"
        product.errors.messages[:name_object_name] = product.errors.messages.delete(:"name_object.name")
      end
      render json: { errors: product.errors.messages }, status: :unprocessable_entity
    else
      current_user.cart.total += Product.price(current_user.products_count + current_user.cart.products.size)
      current_user.cart.products << product
      render json: { cartHTML: "#{render_to_string partial: 'users/cart', locals: { cart: current_user.cart }}" }
    end
  end

  def add_and_checkout
    if current_user.cart.nil?
      current_user.cart = Cart.create
    end
    product = build_product_from_params
    unless product.errors.messages.empty?
      if product.errors.messages.has_key? :"name_object.name"
        product.errors.messages[:name_object_name] = product.errors.messages.delete(:"name_object.name")
      end
      render json: { errors: product.errors.messages }, status: :unprocessable_entity
    else
      current_user.cart.total += Product.price(current_user.products_count + current_user.cart.products.size)
      current_user.cart.products << product
      render 'checkout'
    end
  end

  def checkout

  end

  def renew
    if current_user.cart.nil?
      current_user.cart = Cart.create
    end
    product = Product.find params[:id]
    unless product.nil?
      current_user.cart.total += 500 #change with renewal pricing
      current_user.cart.products << product
      render 'checkout'
    end
  end

  def pay_for_cart
    # Create the charge on Stripe's servers - this will charge the user's card
    amount = current_user.cart.total
    if amount == 0
      flash[:danger] = "Cart was empty. Please register a product and try again"
      redirect_to new_product_path and return
    end
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
          description: "Product registration on Cognate",
        )
        t.charge_id = charge.id
      else
        t.charge_id = "free"
        amount = 0
      end
      t.amount = amount
      t.coupon = coupon
      coupon.number_of_uses = coupon.number_of_uses - 1 unless coupon.nil?
      t.user = current_user
    rescue Stripe::CardError => e
      # The card has been declined
      flash.now[:warning] = "The card has been declined"
      paid = false
    else
      paid = true

      cart_size = current_user.cart.products.size
      if cart_size == 1
        product_to_render = current_user.cart.products[0]
      end
      current_user.cart.products.each do |product|
        product.cart_id = nil
        product.save
      end
      current_user.cart.products = []
      current_user.cart.save
    end

    flash[:success] = "Transaction successful"
    if product_to_render.nil?
      redirect_to :profile
    else
      redirect_to product_to_render
    end
  end

  def build_product_from_params
    @product = Product.new(product_params)
    if signed_in?
      @product.name_object.user = current_user
    end

    if @product.is_service
      top_level_product_type_id = params[:top_level_product_type_services][:product_type_id]
    else
      top_level_product_type_id = params[:top_level_product_type_goods][:product_type_id]
    end
    unless top_level_product_type_id.blank?
      top_level_product_type = ProductType.find(top_level_product_type_id)
      @product.product_types << top_level_product_type
      params[:product_product_types].split(";").each do |product_type|
        product_type_obj = ProductType.find_or_initialize_by(label: product_type.strip)
        if product_type_obj.id.nil?
          product_type_obj.parent = top_level_product_type
          product_type_obj.save
        end
        @product.product_types << product_type_obj
      end
    end

    business_name = params[:product][:business_name]
    business_name_obj = NameObject.find_by name: business_name
    @product.business_name = business_name
    if business_name_obj.nil?
      @product.business = nil
    else
      @product.business = Business.find business_name_obj.nameable_id
    end

    if @product.save
      #upload image
      image = params[:product][:product_image_file]
      logger.debug image.inspect
      if not image.nil?
        @product.product_image_filename = save_image_file(image, @product).to_s
        @product.save
      end

      #upload image
      logo = params[:product][:logo_image_file]
      logger.debug logo.inspect
      if not logo.nil?
        @product.logo_image_filename = save_logo_file(logo, @product).to_s
        @product.save
      end
    end

    return @product
  end

  def edit
    @is_new = false
    @product = Product.find(params[:id])
    @goods = ProductType.find_by(label: "Goods").children.order(:label)
    @services = ProductType.find_by(label: "Services").children.order(:label)
  end

  def update
    @product = Product.find(params[:id])
    @product.update(product_params)
    if signed_in?
      @product.name_object.user = current_user
    end

    if @product.is_service
      top_level_product_type_id = params[:top_level_product_type_services][:product_type_id]
    else
      top_level_product_type_id = params[:top_level_product_type_goods][:product_type_id]
    end
    unless top_level_product_type_id.blank?
      top_level_product_type = ProductType.find(top_level_product_type_id)
      @product.product_types << top_level_product_type
      params[:product_product_types].split(";").each do |product_type|
        product_type_obj = ProductType.find_or_initialize_by(label: product_type.strip)
        if product_type_obj.id.nil?
          product_type_obj.parent = top_level_product_type
          product_type_obj.save
        end
        @product.product_types << product_type_obj
      end
    end

    business_name = params[:product][:business_name]
    business_name_obj = NameObject.find_by name: business_name
    @product.business_name = business_name
    if business_name_obj.nil?
      @product.business = nil
    else
      @product.business = Business.find business_name_obj.nameable_id
    end

    if @product.save
      #upload image
      image = params[:product][:product_image_file]
      if not image.nil?
        @product.product_image_filename = save_image_file(image, @product).to_s
        @product.save
      end

      #upload image
      logo = params[:product][:logo_image_file]
      if not logo.nil?
        @product.logo_image_filename = save_logo_file(image, @product).to_s
        @product.save
      end

      render 'show'
    else
      @is_new = false
      @user_businesses = Business.includes(:name_object).where(name_objects: {user_id: current_user.id})
    end
  end

  def destroy
    @product = Product.find_by_id(params[:id])
    if @product.name_object.user != current_user and not current_user.is_an_admin?
      flash[:danger] = "Not able to delete this object"
      respond_to do |format|
        format.html { redirect_to profile_path }
        format.js {}
      end
    end

    if @product.destroy
      flash[:success] = "Product was successfully deleted."
    else
      flash[:danger] = "Something went wrong"
    end

    @total = current_user.cart.total
    respond_to do |format|
      format.html { redirect_to profile_path }
      format.js { }
    end
  end

  def show
    @product = Product.find_by_id(params[:id])
  end

  def logo_image
    product = Product.find_by_id(params[:id])
    logger.debug product.logo_image_filename
    send_file product.logo_image_filename, disposition: 'inline'
  end

  def full_image
    product = Product.find_by_id(params[:id])
    send_file product.product_image_filename, disposition: 'attachment'
  end

  private
    def product_params
      calc_date_mask('date_of_first_use')
      product = params.required(:product)
                      .permit(:tagline,
                              :is_service,
                              :description,
                              :date_of_first_use,
                              :date_of_first_use_mask,
                              :business_id,
                              { name_object: [ :name,
                                              :id
                                            ]
                              })
      product[:name_object_attributes] = product.delete(:name_object)
      return product
    end

    def populate_product_types
      Rails.cache.fetch('product_types_list') {
        f = File.open("data/product_types.json")
        product_types_list = JSON.parse f.read()
        f.close()
        product_types_list
      }
    end

    def save_image_file(file, product)
      filename = Rails.root.join('data', 'uploads', 'products', product.name_object.user.id.to_s,
                                 product.id.to_s, 'full_image' + File.extname(file.original_filename))
      FileUtils.mkdir_p(File.dirname(filename)) unless File.directory?(File.dirname(filename))
      File.open(filename, 'wb') do |target|
        target.write(file.read)
      end
      return filename
    end

    def save_logo_file(file, product)
      filename = Rails.root.join('data', 'uploads', 'products', product.name_object.user.id.to_s,
                                 product.id.to_s, 'logo' + File.extname(file.original_filename))
      FileUtils.mkdir_p(File.dirname(filename)) unless File.directory?(File.dirname(filename))
      File.open(filename, 'wb') do |target|
        target.write(file.read)
      end
      return filename
    end

    #run before params get used to create product
    def calc_date_mask(field_name)
      if params[:product][:"#{field_name}(2i)"] == '' and params[:product][:"#{field_name}(3i)"] != ''
        return
      elsif params[:product][:"#{field_name}(2i)"] == ''
        params[:product][:"#{field_name}(2i)"] = '1'
        params[:product][:"#{field_name}(3i)"] = '1'
        params[:product][:"#{field_name}_mask"] = :year
      elsif params[:product][:"#{field_name}(3i)"] == ''
        params[:product][:"#{field_name}(3i)"] = '1'
        params[:product][:"#{field_name}_mask"] = :year_month
      else
        params[:product][:"#{field_name}_mask"] = :year_month_day
      end
    end

    def sort_column
      permissible = Product.column_names.clone.map { |name| Product.table_name + "." + name }
      n = NameObject.column_names.clone.map { |name| NameObject.table_name + "." + name}
      permissible.concat(n)
      permissible.include?(params[:sort]) ? params[:sort] : "name_objects.name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
