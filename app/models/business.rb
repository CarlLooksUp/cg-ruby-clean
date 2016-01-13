class Business < ActiveRecord::Base
  include ConditionalValidations

  PartialDate = Struct.new(:year, :month, :day)

  before_destroy :destroy_name_object
  before_create :generate_serial_number
  after_create :invalidate_count
  before_validation :phone_format

#  fields: location, tagline, sic_code, website, phone, entity_type,
#          in_use, date_of_first_use, plans_for_use,
#          proof_of_use_filename, source, status
#          address1, address2, city, state, zip_code

# Constants
  COGNAME_USER_ID = 3
  DATE_MASK_OPTIONS = [:year_month_day, :year_month, :year]
  has_one :name_object, as: :nameable
  has_one :user, through: :name_object
  accepts_nested_attributes_for :name_object
  belongs_to :price_tier
  belongs_to :state
  #belongs_to :source
  has_many :products


# Validations
  conditionally_validates :city, presence: true
  conditionally_validates :state, presence: true, format: { with: /\A[A-Z][A-Z]\z/, message: "Please use state abbreviation" }
  conditionally_validates :zip_code, format: { with: /(\A\d{5}(-\d{4})?\z)|()/, message: "Please use a valid zip code format" }
  conditionally_validates :phone, format: { with: /(\A[x\d]+\z)|(\A\z)/, message: "Please use a valid phone number format" }
  conditionally_validates :sic_code, presence: true
  conditionally_validates :in_use, inclusion: { in: [true, false] }
  conditionally_validates :is_interstate, inclusion: { in: [true, false] }, if: :in_use
  conditionally_validates :proof_of_use_filename, presence: true, if: :in_use
  conditionally_validates :date_of_first_use, presence: true, if: :in_use
  conditionally_validates :plans_for_use, presence: true, unless: :in_use
  conditionally_validates :planned_date, presence: true, unless: :in_use

  scope :owned_by, ->(user_id) { includes(:name_object).where(name_objects: { user_id: user_id }) }

  #for admin view
  def self.search_user_submitted_by_name(search)
    scope_ = Business.joins(:name_object)
                     .where('name_objects.user_id != ?', COGNAME_USER_ID)
    if search
      scope_.where('name_objects.name ILIKE ?', "%#{search}%")
    else
      scope_
    end
  end

  def self.filtered_search(search = "", state_id = "",source_id = "")
    
      if ActiveRecord::Base.connection.adapter_name == "PostgreSQL"
        #clean_search = search_clean(search)
        if search.blank? && state_id.blank? && source_id.blank?
          Business.joins(:name_object)
        else
          clean_search = search
          #clean_search = search_clean(search)
          filter = term_filter(clean_search,state_id,source_id)
          Business.joins(:name_object).where(filter)
        end 
      else #not postgres, no token index

        Business.joins(:name_object).where('name_objects.name ILIKE ?', "%#{search}%")
      end

  end
    
  def self.term_filter(search="", state_id="",source_id="")
    args = {search_term: search , state_term: state_id , source_term: source_id }
    query_string = ""
    args.each do |key, value|
      unless value.blank? 
        if key == :search_term 
          #clean_search = search_clean(value)
          query_string = "name_search @@ to_tsquery('english', '#{value}')"
        elsif key == :state_term && query_string.size == 0
          query_string = "state_id = #{value}" 
        elsif key == :state_term && query_string.size > 0
          query_string = query_string + " and state_id = #{value}" 
        elsif key == :source_term && query_string.size == 0 
          query_string = "source_id = #{value}" 
        elsif key == :source_term && query_string.size > 0 
          query_string = query_string + " and source_id = #{value}" 
        else
          query_string
        end
      end
    end
    return query_string
  end  




  #Must be accesible from controller
  def send_admin_email
    UserMailer.biz_notification(self).deliver
  end

  def send_user_email
    UserMailer.reg_notification(self).deliver
  end

  def generate_serial_number
    num = SecureRandom.hex(8)
    unless Business.find_by(serial_number: num).nil?
      self.generate_serial_number
    else
      self.serial_number = num
    end
  end

  #Manually doing work of enum
  def planned_date_mask
    DATE_MASK_OPTIONS[read_attribute(:planned_date_mask)]
  end

  def planned_date_mask=(value)
    write_attribute(:planned_date_mask, DATE_MASK_OPTIONS.index(value))
  end

  def planned_date_to_s
    self.planned_date.to_s(self.planned_date_mask)
  end

  def date_of_first_use_mask
    DATE_MASK_OPTIONS[read_attribute(:date_of_first_use_mask)]
  end

  def date_of_first_use_mask=(value)
    write_attribute(:date_of_first_use_mask, DATE_MASK_OPTIONS.index(value))
  end

  def date_of_first_use_to_s
    self.date_of_first_use.to_s(self.date_of_first_use_mask)
  end

  def date_for_editing(field_name)
    date = self.send(field_name)
    mask = self.send(field_name + "_mask")
    unless date.nil?
      if mask == :year
        date = PartialDate.new(date.year, nil, nil)
      elsif mask == :year_month
        date = PartialDate.new(date.year, date.month, nil)
      end
    end
    date
  end

  def to_s
    self.name_object.name
  end

  private
    def destroy_name_object
      self.name_object.destroy
    end

    def invalidate_count
      Rails.cache.delete('biz_count')
    end

    def phone_format
      self.phone.tr!(" \\-.", "")
    end  


end
