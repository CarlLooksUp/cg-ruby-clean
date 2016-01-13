class Product < ActiveRecord::Base
  include ConditionalValidations
  PartialDate = Struct.new(:year, :month, :day)

  before_destroy :destroy_name_object

  DATE_MASK_OPTIONS = [:year_month_day, :year_month, :year]
  has_one :name_object, as: :nameable
  has_one :user, through: :name_object
  has_and_belongs_to_many :product_types
  belongs_to :business
  accepts_nested_attributes_for :name_object

  #Validations
  conditionally_validates :date_of_first_use, presence: true
  conditionally_validates :is_service, inclusion: { in: [true, false] }
  conditionally_validates :top_level_product_type, presence: true
  conditionally_validates :product_image_filename, presence: true

  def self.search_by_name(search)
    if search
      Product.joins(:name_object).where('name_objects.name ILIKE ?', "%#{search}%")
    else
      Product.joins(:name_object)
    end
  end

  def payment_expired?
    false
  end

  def owner_name
    if self.business.nil? and self.business_name.blank?
      if self.name_object.user.username.blank?
        self.name_object.user.first_name + " " + self.name_object.user.last_name
      else
        self.name_object.user.username
      end
    elsif self.business.nil?
      self.business_name
    else
      self.business.name_object.name
    end
  end

  def owner_type
    if self.business.nil?
      "profile"
    else
      "business"
    end
  end

  def self.price(count)
    if count < 1
      2995
    elsif count < 6
      1495
    elsif count < 16
      1095
    elsif count < 30
      895
    elsif count < 70
      695
    elsif count < 100
      555
    elsif count < 400
      450
    elsif count < 800
      350
    elsif count < 1000
      250
    elsif count < 1200
      150
    else
      80
    end
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

  def to_s
    self.name_object.name
  end

  private
    def destroy_name_object
      self.name_object.destroy
    end
end
