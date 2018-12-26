class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :load_user, only: %i(show edit update destroy)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate page: params[:page],
      per_page: Settings.app.controllers.users_controller.perpage
  end

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "controllers.users_controller.checkemail"
      redirect_to root_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = t "controllers.users_controller.updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.delete
      flash[:success] = t "controllers.users_controller.deleted_success"
      redirect_to users_path
    else
      flash[:danger] = t "controllers.users_controller.deleted_unsuccess"
      redirect_to root_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password,
      :password_confirmation)
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t "controllers.users_controller.user_notfound"
    redirect_to root_path
  end

  # Before filters

  # Confirms a logged-in user.
  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "controllers.users_controller.errorlogin"
    redirect_to login_url
  end

  # Confirms the correct user.
  def correct_user
    redirect_to(root_path) unless current_user?(@user)
  end

  # Confirms an admin user.
  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end
end
