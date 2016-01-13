class User < ActiveRecord::Base
  # fields: email, name, username, password, password_confirmation
  before_save { self.email = email.downcase }
  before_create :create_remember_token
  after_create :send_admin_email, :send_signup_notification
  has_secure_password

  validates :last_name, presence: true, length: { maximum: 100 }
  validates :first_name, presence: true, length: { maximum: 100 }
  validates :username, length: { maximum: 50 }, uniqueness: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :password, presence: { on: :create },
                       length: { minimum: 6, allow_blank: true }

  has_many :name_objects
  has_many :transactions
  has_and_belongs_to_many :roles
  has_one :cart

  blogs

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.encrypt(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def send_password_reset
    token = SecureRandom.urlsafe_base64
    self[:password_reset_token] = token
    self[:password_reset_sent_at] = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

  def send_signup_notification
    UserMailer.signup_notification(self).deliver
  end

  def method_missing(method_id, *args)
    if match = matches_dynamic_role_check?(method_id)
      tokenize_roles(match.captures.first).each do |check|
        self.roles.each do |role|
          return true if role.name.downcase == check
        end
      end
      return false
    else
      super
    end
  end

  def display_name
    if self.username.nil?
      self.name
    else
      self.username
    end
  end

  def name
    first = (self.first_name.nil? ? "" : self.first_name)
    last = (self.last_name.nil? ? "" : self.last_name)
    first + " " + last
  end

  def products_count
    Product.joins(:name_object).where('name_objects.user_id=?', self.id).where(cart_id: nil).count
  end

  private
    
    def create_remember_token
      self.remember_token = User.encrypt(User.new_remember_token)
    end
    
    def matches_dynamic_role_check?(method_id)
      /^is_an?_([a-zA-Z]\w*)\?$/.match(method_id.to_s)
    end

    def tokenize_roles(string_to_split)
      string_to_split.split(/_or_/)
    end

    def send_admin_email
      UserMailer.user_notification(self).deliver unless Rails.env.development?
    end
end
