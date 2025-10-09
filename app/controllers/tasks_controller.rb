class TasksController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :project
  load_and_authorize_resource through: :project

  def index
    if current_user.contributor?
      # @tasks = Task.includes(:user_as_contributor).where(users: {id: current_user.id})
      @tasks = Task.where(contributor_id: current_user.id, project_id: params[:project_id])
      # @projects = Project.includes(@tasks)
      
    elsif current_user.manager?
      # byebug
      @tasks = Task.includes(:project).where(projects: { id: params[:project_id], manager_id: current_user.id })
      @contributor = User.find(@tasks.pluck(:contributor_id)).first

    else
      # @tasks = Task.none
      @tasks = Task.includes(:project).where(projects: {id: params[:project_id]})
    end
    # byebug

    # @tasks = @tasks.where(status: params[:status]) if params[:status].present?
    @tasks = @tasks.order(:id).page(params[:page]).per(10)

  end
  
  def new
    # byebug
    @task = @project.tasks.build
  end

  def create
    # byebug
    @task = @project.tasks.build(task_params)
    @task.status = 'not_started'
    
    if @task.save
      flash[:notice] = "Task \"#{@task.title}\" Created Successfully!"
      redirect_to project_task_path(@project, @task)
    else
      flash.now[:alert] = @task.errors.full_messages
      render :new, status: :unprocessable_content
    end
  end

  def show
    @project = Project.find(params[:project_id])
    @task = Task.find(params[:id])
    @contributor = User.find(@task.contributor_id)
    # render json: @project, include: [:manager, :tasks], status: :ok
  end

  def edit
    @task = @project.tasks.find(params[:id])
  end

  def update
    if @task.update(task_params)
      # render json: @task, status: :ok
      flash[:notice] = "Task \"#{@task.title}\" Updated Successfully!"
      redirect_to project_task_path(@project, @task)
    else
      flash.now[:alert] = @task.errors.full_messages
      render :edit, status: :unprocessable_content
      # render json: { errors: @task.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @task = Task.find(params[:id])
    @project = Project.find(params[:project_id])
    @task.destroy
    flash[:alert] = "Task \"#{@task.title}\" Deleted Successfully!"
    redirect_to project_tasks_path(@project)
  end

  private
    def task_params
      params.require(:task).permit(:title, :description, :status, :project_id, :contributor_id)
    end
end
