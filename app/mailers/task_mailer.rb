class TaskMailer < ApplicationMailer
  def reminder_email(user, task, days_before)
    @user = user
    @task = task
    @days_before = days_before

    mail(
      to: @user.email,
      subject: "Reminder: Task '#{@task.title}' due in #{@days_before} day(s)"
    )
  end
end 