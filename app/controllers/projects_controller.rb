class ProjectsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  def index
    if current_user.admin?
      projects = Project.includes(:manager).all
      
      projects = @projects.where(manager_id: params[:manager_id]) if params[:manager_id].present?

    elsif current_user.manager?
      projects = Project.includes(:manager).where(manager_id: current_user.id).order(created_at: :desc).limit(10).offset(0)
    elsif current_user.contributor?
      projects = Project.includes(:manager, tasks: :user_as_contributor).where(tasks: { user_as_contributor: current_user }).distinct
    else
      @project = Project.none
    end

    projects = projects.where(status: params[:status]) if params[:status].present?
    @projects = projects.order(created_at: :desc).page(params[:page]).per(10)

  end

  def show
    @project = Project.includes(:manager).find(params[:id])
    # render json: @project, include: [:manager, :tasks], status: :ok
  end

  def new
    @project = Project.new
  end

  def create
    project = Project.new(project_params)
    project.manager_id = current_user.id
    project.status = 'active'

    if project.save
      flash[:notice] = "Project \"#{project.title}\" created successfully!"
      redirect_to project_path(project)
    else
      flash.now[:alert] = project.errors.full_messages.to_sentence
      @project = project
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    @project = Project.find(params[:id])

    if @project.update(project_params)
      flash[:notice] = "Project \"#{@project.title}\" updated successfully!"
      redirect_to projects_path(@project)
    else
      flash.now[:alert] = @project.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_content
    end
  end



  def destroy
    project = Project.find(params[:id])

    if project.destroy
      flash[:notice] = "Project \"#{project.title}\" was successfully deleted."
      redirect_to projects_path
    else
      flash[:alert] = "Project could not be deleted."
      redirect_to project_path(project)
    end
  end

  def search_project
    query = params[:query].to_s.strip
    status = params[:status].to_s.strip

    if query.empty? && (status.empty? || status == "All Status")
      flash[:alert] = "Please enter a search query or select a status."
      redirect_to projects_path and return
    end

    if query.present?
      response = Project.search(query)
      # logger.info "Elasticsearch results: #{response.results.total}"
      # results = response.records
      if user_signed_in? && current_user.manager?
        results = response.records.includes(:manager).where(manager_id: current_user.id)
      elsif user_signed_in? && current_user.contributor?
        results = response.records.includes(:tasks, :manager).where(tasks: { contributor_id: current_user.id })
      else
        results = response.records
      end
    else
      if user_signed_in? && current_user.manager?
        results = Project.includes(:manager).where(manager_id: current_user.id)
      elsif user_signed_in? && current_user.contributor?
        results = Project.includes(:tasks, :manager).where(tasks: { contributor_id: current_user.id })
      else
        results = Project.includes(:manager).all
      end
    end

    results = results.where(status: status) unless status.empty? || status == "All Status"

    @projects = results
    render :search_project
  end

  private
    def project_params
      params.require(:project).permit(:title, :description, :status)
    end
end
