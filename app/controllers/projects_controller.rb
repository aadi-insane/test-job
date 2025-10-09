class ProjectsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    if current_user.admin?
      @projects = Project.includes(:manager, :tasks).all
    elsif current_user.manager?
      @projects = Project.includes(:manager, :tasks).where(manager_id: current_user.id)
    elsif current_user.contributor?
      @projects = Project.includes(tasks: :user_as_contributor).where(users: {id: current_user.id})
    else
      @project = Project.none
    end

    @projects = @projects.where(status: params[:status]) if params[:status].present?
    @projects = @projects.order(created_at: :desc).page(params[:page]).per(10)

  end

  def show
    @project = Project.find(params[:id])
    # render json: @project, include: [:manager, :tasks], status: :ok
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.manager_id = current_user.id
    @project.status = 'active'

    if @project.save
      flash[:notice] = "Project \"#{@project.title}\" created successfully!"
      redirect_to project_path(@project)
    else
      flash.now[:alert] = @project.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    if @project.update(project_params)
      # render json: @project, status: :ok
      flash[:notice] = "Task \"#{@project.title}\" Updated Successfully!"
      redirect_to projects_path(@project)
    else
      flash.now[:alert] = @project.errors.full_messages
      render :edit, status: :unprocessable_content
      # render json: { errors: @project.errors.full_messages }, status: :unprocessable_content
    end
  end


  def destroy
    @project = Project.find(params[:id])

    if @project.destroy
      flash[:notice] = "Project \"#{@project.title}\" was successfully deleted."
      redirect_to projects_path
    else
      flash[:alert] = "Project could not be deleted."
      redirect_to project_path(@project)
    end
  end

  private
    def project_params
      params.require(:project).permit(:title, :description, :status)
    end
end
