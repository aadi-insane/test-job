class ProjectCompletionWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options queue: 'project_completion', retry: 5, unique: :until_and_while_executing

  def perform(project_id)
    project = Project.find_by(id: project_id)
    return unless project

    if project.tasks.all?(&:completed?)
      project.update!(status: 'completed')
      ProjectMailer.completion_email(project.manager, project).deliver_now

    end
  end

  # def perform(project_id)
  #   project = Project.find_by(id: project_id)
  #   return unless project

  #   completed_flags = project.tasks.map { |t| [t.id, t.completed?] }
  #   Rails.logger.info "Tasks completion status: #{completed_flags.inspect}"

  #   if project.tasks.all?(&:completed?)
  #     project.update!(status: 'completed')
  #     Rails.logger.info "Sending completion email to #{project.manager.email}"
  #     ProjectMailer.completion_email(project.manager, project).deliver_now
  #   else
  #     Rails.logger.info "Not all tasks are completed for project #{project.id}"
  #   end
  # end

end
