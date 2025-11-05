class UsersController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    @users = User.all.page(params[:page]).per(10)
  end

  def search_user
    query = params[:query].to_s.strip
    status = params[:status].to_s.strip

    if query.empty? && (status.empty? || status == "All Status")
      flash[:alert] = "Please enter a search query or select a status."
      redirect_to users_path and return
    end

    if query.present?
      results = User.search(query).records
    else
      results = User.all
    end

    results = results.where(status: status) unless status.empty? || status == "All Status"
    results = results.page(params[:page]).per(10)

    flash.now[:notice] = "'#{results.total_count}' results found." if results.exists?
    flash.now[:alert] = "No results found." unless results.exists?

    @users = results
    render :index
  end
end
