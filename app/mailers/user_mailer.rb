class UserMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  default from: "support@cognate.com"
  helper CouponsHelper
  layout 'email'

  STATUS_FLAGS = { "In Use" => "full",
                   "Not In Use" => "not-in-use" }

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Cognate.com Password Reset"
  end

  def signup_notification(user)
    @user = user
    mail to: user.email, subject: "Welcome to Cognate.com"
  end

  def reg_notification(biz)
    @biz = biz
    attachments.inline['coglogo-color.png'] = File.read("#{Rails.root}/app/assets/images/coglogo-color-email.png")
    attachments.inline['coglogo-small.png'] = File.read("#{Rails.root}/app/assets/images/coglogo.png")
    @status = STATUS_FLAGS.key(@biz.status)
    mail to: @biz.user.email, subject: "Thanks for Registering on Cogname"
  end

  def biz_expire_notification(biz)
    @biz = biz
    mail to: "carl.morrissey@gmail.com", subject: "Your registration for " + @biz.name_object.name + " is about to expire"
  end

  def user_notification(user)
    @user = user
    admin_emails = "carl.morrissey@gmail.com, bcollen@cognate.com"
    mail to: admin_emails, subject: "New User"
  end

  def biz_notification(biz)
    @biz = biz
    logger.debug "Sending email for " + @biz.name_object.name
    admin_emails = "carl.morrissey@gmail.com, bcollen@cognate.com"
    mail to: admin_emails, subject: "New Business"
  end

  def coupon_offer(coupon, email)
    @coupon = coupon
    logger.debug "Sending coupon offer to: " + email
    attachments.inline['coglogo-color.png'] = File.read("#{Rails.root}/app/assets/images/coglogo-color-email.png")
    attachments.inline['coglogo-small.png'] = File.read("#{Rails.root}/app/assets/images/coglogo.png")
    mail to: email, subject: "Your Coupon for Cognate.com"
  end

  def uspto_mailing(email, tm_name, first_name)
    @trademark = tm_name 
    @first_name = first_name
    logger.debug "Sending USPTO mailing to: " + email
    mail to: email, subject: "Alternative Trademark Listing – Claim Your Rights Today" do |format|
      format.html { render layout: 'mailchimp' }
      format.text
    end
  end
end
