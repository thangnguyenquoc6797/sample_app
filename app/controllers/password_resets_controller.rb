class PasswordResetsController < ApplicationController
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update] # Case (1)

  def new; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "controllers.password_resets_controller.rightemail"
      redirect_to root_url
    else
      flash.now[:danger] = t "controllers.password_resets_controller.wrongemail"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty? # Case (3)
      @user.errors.add :password,
        t("controllers.password_resets_controller.emptypass")
      render :edit
    elsif @user.update_attributes(user_params) # Case (4)
      log_in @user
      @user.update_attribute :reset_digest, nil
      flash[:success] = t "controllers.password_resets_controller.resetpass"
      redirect_to @user
    else
      render :edit # Case (2)
    end
  end

  private

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  # Before filters

  def get_user
    @user = User.find_by email: params[:email]
  end

  # Confirms a valid user.
  def valid_user
    return if @user&.activated? && @user.authenticated?(:reset, params[:id])

    redirect_to root_url
  end

  # Checks expiration of reset token.
  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t "controllers.password_resets_controller.expiredpass"
    redirect_to new_password_reset_url
  end
end
