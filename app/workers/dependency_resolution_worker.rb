class DependencyResolutionWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options queue: 'dependency_resolution', retry: 5, unique: :until_executed

  def perform(completed_task_id)
    completed_task = Task.find_by(id: completed_task_id)
    return unless completed_task && completed_task.status == 'completed'

    completed_task.dependent_tasks.each do |dep_task|
      incomplete_prerequisites = dep_task.prerequisite_tasks.where(status: ['not_started', 'in_progress'])

      if incomplete_prerequisites.exists?
        dep_task.update(status: 'blocked')
      else
        dep_task.update(status: 'in_progress')

        DependencyMailer.unblock_notification(dep_task.user_as_contributor, completed_task, dep_task).deliver_now
      end
    end
  end
end
