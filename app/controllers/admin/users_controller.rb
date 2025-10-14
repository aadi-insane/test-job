class Admin::UsersController < ApplicationController
  before_action :authenticate_admin!

  def index
    users = User.order(:id)
    users = users.where(role: params[:role]) if params[:role].present?
    @users = users.page(params[:page]).per(10)
  end

  private

  def authenticate_admin!
    unless user_signed_in? && current_user.admin?
      redirect_to root_path, alert: "Access denied."
    end
  end
end
