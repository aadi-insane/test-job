class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception, unless: -> { request.format.json? }
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

  private
    def record_not_found(exception)
      redirect_to root_path
      flash[:alert] = "Record Not Found!"
    end

end