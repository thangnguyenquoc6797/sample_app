class SessionsController < ApplicationController
  before_action :load_user_by_mail, only: :create

  def new; end

  def create
    if @user&.authenticate(params[:session][:password])
      if @user.activated?
        activated @user
      else
        flash[:warning] = t("controllers.sessions_controller.notactivated")
        redirect_to root_url
      end
    else
      flash.now[:danger] = t("controllers.sessions_controller.danger")
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  def activated user
    log_in user
    if params[:session][:remember_me] == Settings.app.controllers.sessions_controller.remember_1
      remember user
    else
      forget user
    end
    redirect_back_or user
  end

  def load_user_by_mail
    @user = User.find_by email: params[:session][:email].downcase
    return if @user
  end
end
