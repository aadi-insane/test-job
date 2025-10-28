class TasksController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :project
  load_and_authorize_resource :task, through: :project

  def index
    if current_user.contributor?
      # @tasks = Task.includes(:user_as_contributor).where(users: {id: current_user.id})
      tasks = Task.includes(:user_as_contributor).where(contributor_id: current_user.id, project_id: params[:project_id])
    elsif current_user.manager?
      # byebug
      tasks = Task.includes(:project, :user_as_contributor).where(projects: { id: params[:project_id], manager_id: current_user.id })
    else
      tasks = Task.includes(:project).where(projects: { id: params[:project_id] })
    end
    @tasks = tasks.order(:id).page(params[:page]).per(10)
  end

  def new
    # byebug
    @task = @project.tasks.build
  end

  def create
    # byebug
    @task = @project.tasks.build(task_params.except(:dependent_task_ids))
    @task.status = 'not_started'

    contributor_ids_on_project = @project.tasks.pluck(:contributor_id)
    if contributor_ids_on_project.include?(@task.contributor_id)
      flash.now[:alert] = "This Contributor is already assigned to this Project can't assign again!"
      render :new, status: :unprocessable_content
      return
    end

    if @task.save
      if params[:task][:dependent_task_ids].present?
        params[:task][:dependent_task_ids].reject(&:blank?).each do |dep_id|
          @task.task_dependencies.create(dependent_task_id: dep_id)
        end
      end
      flash[:notice] = "Task \"#{@task.title}\" Created Successfully!"
      redirect_to project_task_path(@project, @task)
    else
      flash.now[:alert] = @task.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end

  def show
    # @task = @project.tasks.includes(:user_as_contributor, :dependent_tasks).find(params[:id])
    @task = @project.tasks.find(params[:id])
  end

  def edit
    @task = @project.tasks.find(params[:id])
  end

  def update
    old_contributor_id = @task.contributor_id
    new_contributor_id = task_params[:contributor_id].to_i if task_params[:contributor_id].present?

    if (current_user.admin? || current_user.manager?) && new_contributor_id && new_contributor_id != old_contributor_id
      assigned_contributors = @project.tasks.where.not(id: @task.id).pluck(:contributor_id).compact
      if assigned_contributors.include?(new_contributor_id)
        flash[:alert] = "This contributor is already assigned to another task in this project."
        redirect_to edit_project_task_path(@project, @task) and return
      else
        @task.update_column(:contributor_id, new_contributor_id)
        @task.update_column(:status, 'not_started')
      end
    end

    if params[:task][:dependent_task_ids].present?
      @task.task_dependencies.destroy_all
      params[:task][:dependent_task_ids].reject(&:blank?).each do |dep_id|
        @task.task_dependencies.create(dependent_task_id: dep_id)
      end
    end

    status_updated_by_aasm = false
    
    if task_params[:status].present? && task_params[:status] != @task.status
      status_updated_by_aasm = true
      begin
        case task_params[:status]
        when 'in_progress'
          @task.start!
        when 'completed'
          if @task.dependencies_completed?
            @task.complete!
          else
            flash.now[:alert] = "Cannot mark task as completed. All dependent tasks must be completed first."
            render :edit, status: :unprocessable_content and return
          end
        end
      rescue AASM::InvalidTransition => e
        flash.now[:alert] = e.message
        render :edit, status: :unprocessable_content and return
      end
    end

    params_to_update = task_params.except(:contributor_id)
    params_to_update = params_to_update.except(:status) if status_updated_by_aasm

    if @task.update(params_to_update)
      flash[:notice] = "Task \"#{@task.title}\" Updated Successfully!"
      redirect_to project_task_path(@project, @task)
    else
      flash.now[:alert] = @task.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    task = @project.tasks.find(params[:id])
    task.destroy
    flash[:alert] = "Task \"#{task.title}\" Deleted Successfully!"
    redirect_to project_tasks_path(@project)
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
      params.require(:task).permit(:title, :description, :status, :project_id, :contributor_id, :due_date, dependent_task_ids: [])
    end

end
