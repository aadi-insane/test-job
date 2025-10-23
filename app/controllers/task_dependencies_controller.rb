class TaskDependenciesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :task

  def create
    dependent_task = Task.find(params[:dependent_task_id])
    authorize! :update, @task
    authorize! :read, dependent_task

    @task.dependent_tasks << dependent_task unless @task.dependent_tasks.include?(dependent_task)
    render json: { message: "Dependency added" }, status: :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end
