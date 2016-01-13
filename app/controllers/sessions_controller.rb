class SessionsController < ApplicationController
  def new
    @user = User.new  
  end

  def create
    user = User.find_by_email(params[:session][:email])
    if user && user.authenticate(params[:session][:password])
      sign_in user
      flash[:success] = "Welcome back!"
      redirect_to root_path
    else
      flash.now[:danger] = "Invalid login"
      @user = User.new
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
