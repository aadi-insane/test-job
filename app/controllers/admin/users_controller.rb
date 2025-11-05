class Admin::UsersController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_user, only: [:edit, :update]

  def index
    # Start with search if query is present
    if params[:query].present?
      users = User.search(params[:query]).records
    else
      users = User.all
    end

    # Apply role filter
    users = users.where.not(role: 'admin')
    users = users.where(role: params[:role]) if params[:role].present?

    # Pagination
    @users = users.order(:id).page(params[:page]).per(10)
  end

  def show
    user = User.find(params[:id])

    if user.manager?
      @user = User.includes(:projects_as_manager).find(params[:id])
    else
      @user = User.includes(tasks_as_contributor: :project).find(params[:id])
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User updated successfully."
    else
      render :edit
    end
  end

  private

    def authenticate_admin!
      unless user_signed_in? && current_user.admin?
        redirect_to root_path, alert: "Access denied."
      end
    end

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :role, :status)
    end
end
