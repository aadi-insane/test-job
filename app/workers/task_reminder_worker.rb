class TaskReminderWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options queue: 'task_reminders', retry: 5, unique: :until_executed

  def perform(task_id, days_before = 1)
    task = Task.find_by(id: task_id)
    return unless task && !task.completed? && task.user_as_contributor

    TaskMailer.reminder_email(task.user_as_contributor, task, days_before).deliver_now
  end
end
