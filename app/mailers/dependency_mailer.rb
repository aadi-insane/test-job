class DependencyMailer < ApplicationMailer
  def unblock_notification(user, completed_task, dependent_task)
    return unless user.present?
    @user = user
    @completed_task = completed_task
    @dependent_task = dependent_task
    mail(to: @user.email, subject: "Your task is now unblocked: #{@dependent_task.title}")
  end
end
