class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      log_in user
      check_rememember user
      redirect_back_or user
    else
      flash.now[:danger] = t("controllers.sessions_controller.danger")
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end

  def check_rememember user
    if params[:session][:remember_me] == Settings.app.controllers.sessions_controller.remember_1
      remember user
    else
      forget user
    end
  end
end
