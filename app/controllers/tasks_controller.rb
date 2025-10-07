class TasksController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    if current_user.contributor?
      @tasks = Task.includes(:project).where(contributor_id: current_user.id).order(:id)
    else
      @tasks = Task.includes(:project).where(project_id: params[:project_id], projects: {manager_id: current_user.id}).order(:id)
    end
  end

end
