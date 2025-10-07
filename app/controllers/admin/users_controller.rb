    # app/controllers/admin/users_controller.rb
    class Admin::UsersController < ApplicationController
      before_action :authenticate_admin! # Or a similar authorization check

      def index
        @users = User.all.order(:id)
      end

      private

      def authenticate_admin!
        user_signed_in? && current_user.admin?
        redirect_to root_path, alert: "Access denied." unless current_user&.admin?
      end
    end