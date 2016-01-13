require 'stripe'

class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update, :upgrade, :destroy]
  before_action :signed_in_admin, only: [:index]
  helper_method :sort_column, :sort_direction

  def new
    @user = User.new
  end

  def edit
    @user = user_or_id_if_admin #make more flexible for admin?
  end

  def show
    @user = user_or_id_if_admin
    @name_objects = @user.name_objects

    #limit to search term if supplied
    if params[:search]
      @name_objects = @name_objects.where('name ILIKE ?', "%#{params[:search]}%")
    end

    @name_objects = @name_objects.order(sort_column + " " + sort_direction).paginate(:page => params[:page], :per_page => 200)
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash.now[:success] = "You've successfully created an account"
      respond_to do |format|
        format.html { redirect_to @user }
        format.json { render json: @user, status: :created }
      end
    else
      flash.now[:danger] = "There was a problem with registration"
      respond_to do |format|
        format.html {
          render 'new'
        }
        format.json {
          render json: {errors: @user.errors}, status: :bad_request
        }
      end
    end
  end

  def index
    @users = User.all.order(sort_column("last_name") + " " + sort_direction).paginate(:page => params[:page], :per_page => 20)
  end

  def update
    @user = user_or_id_if_admin
    to_update = user_params

    #check credentials and whether user wants to change pass
    if (params[:new_password] and (not @user.authenticate(params[:current_password]) or not @user.is_an_admin?))
      flash[:warning] = "That password does not match"
      render 'edit'
    elsif not params[:new_password]
      to_update.except :password, :password_confirmation
    end

    @user.update(user_params)
    if @user.save
      flash[:success] = "Your profile has been updated."
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    user = user_or_id_if_admin
    if current_user.id == user.id
      sign_out
    end
    user.destroy
    redirect_to users_path
  end

  def cart
    @cart = current_user.cart
    respond_to do |format|
      format.js
    end
  end

  private
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :username, :password,
                                   :password_confirmation)
    end

    def sort_column(default=nil)
      default = "name" if default.nil?
      permissible = NameObject.column_names.clone
      permissible.include?(params[:sort]) ? params[:sort] : default
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def signed_in_user
      if not signed_in?
        flash[:error] = "Please sign in."
        redirect_to signin_url
      end
    end

    def user_or_id_if_admin
      if current_user.is_an_admin? and not params[:id].blank?
        User.find_by_id(params[:id])
      else
        current_user
      end
    end
end
