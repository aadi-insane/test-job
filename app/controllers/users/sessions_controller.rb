# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # skip_before_action :verify_authenticity_token, only: [:create]

  # respond_to :json
  # before_action :configure_sign_in_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :address])
  # end

  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:name, :address])
  # end

  # private
  #   def respond_with(resource, _opts = {})
  #     render json: {
  #       message: 'Logged in successfully',
  #       token: request.env['warden-jwt_auth.token'],
  #       user: resource
  #     }, status: :ok
  #   end

  #   def respond_to_on_destroy
  #     head :no_content
  #   end
end
