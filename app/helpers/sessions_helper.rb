module SessionsHelper
  def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.current_user = user
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    remember_token = User.encrypt(cookies[:remember_token])
    @current_user ||= User.find_by_remember_token(remember_token)
  end

  def signed_in?
    !current_user.nil?
  end

  def admin?
    signed_in? and current_user.is_an_admin?
  end

  def author?
    signed_in? and current_user.is_a_blog_author?
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end

  def current_user?(user)
    user == current_user
  end

  def signed_in_user
    unless signed_in?
      #store_location
      redirect_to main_app.signin_path, flash: { warning: "Please sign in" }
    end
  end

  def signed_in_admin
    unless signed_in? and current_user.is_an_admin?
      #store_location
      redirect_to main_app.signin_path, flash: { warning: "Please sign in" }
    end
  end

  def login_required
    unless signed_in?
      redirect_to main_app.signin_path, flash: { warning: "Please sign in" }
    end
  end

  def author_required
    unless author?
      redirect_to main_app.signin_path, flash: { warning: "You must be an author" }
    end
  end
end
