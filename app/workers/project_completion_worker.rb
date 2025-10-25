# app/workers/project_completion_worker.rb
class ProjectCompletionWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options queue: 'project_completion', retry: 5, unique: :until_and_while_executing

  def perform(project_id)
    project = Project.find_by(id: project_id)
    return unless project

    if project.tasks.all?(&:completed?)
      project.update!(status: 'completed')
      ProjectMailer.completion_email(project.manager, project).deliver_later
    end
  end
end
