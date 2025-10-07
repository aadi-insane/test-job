class ProjectsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    if current_user.admin?
     @projects = Project.includes(:manager).all
    elsif current_user.manager?
      @projects = Project.includes(:manager).where(manager_id: current_user.id)
    else
      @projects = []
    end
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.manager_id = current_user.id

    if @project.save
      flash[:notice] = "Project \"#{@project.title}\" created successfully!"
      redirect_to project_path(@project)
    else
      flash.now[:alert] = @project.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @project = Project.find(params[:id])
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
    params.require(:project).permit(:title, :description)
  end
end
