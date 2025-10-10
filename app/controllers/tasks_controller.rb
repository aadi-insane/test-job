class TasksController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :project
  load_and_authorize_resource :task, through: :project


  def index
    if current_user.contributor?
      # @tasks = Task.includes(:user_as_contributor).where(users: {id: current_user.id})
      @tasks = Task.includes(:user_as_contributor).where(contributor_id: current_user.id, project_id: params[:project_id])
      
    elsif current_user.manager?
      # byebug
      @tasks = Task.includes(:project, :user_as_contributor).where(projects: { id: params[:project_id], manager_id: current_user.id })

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

    # contributor_ids_on_project = User.where(id: @project.tasks.where(status: 'completed').pluck(:contributor_id)).ids
    contributor_ids_on_project = User.where(id: @project.tasks.pluck(:contributor_id)).ids

    if contributor_ids_on_project.include?(@task.contributor_id)
      flash.now[:alert] = "This Contributor is already assigned to this Project can't assign again!"
      render :new, status: :unprocessable_content
    else
      if @task.save
        flash[:notice] = "Task \"#{@task.title}\" Created Successfully!"
        redirect_to project_task_path(@project, @task)
      else
        flash.now[:alert] = @task.errors.full_messages
        render :new, status: :unprocessable_content
      end
    end
    
  end

  def show
    @project = Project.find(params[:project_id])
    @task = Task.includes(:user_as_contributor).find(params[:id])
    @contributor = @task.user_as_contributor
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

  def update_status
    @task = Task.find(params[:id])
    authorize! :update_status, @task

    if @task.update(task_params)
      # Respond with success
      flash[:notice] = "Task status updated successfully!"
      redirect_to project_task_path(@project, @task)
    else
      # Respond with error
      flash.now[:alert] = @task.errors.full_messages
      render :edit, status: :unprocessable_content
    end
  end

  def deactivate_project
    @project = Project.find(params[:project_id])
    authorize! :deactivate, @project

    if @project.may_deactivate?
      @project.deactivate!
      render json: { message: 'Project deactivated' }, status: :ok
    else
      render json: { error: 'Invalid state transition' }, status: :unprocessable_content
    end
  end

  private

  def task_params
    params.require(:task).permit(:title, :description, :status, :project_id, :contributor_id)
  end
end
