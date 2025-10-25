class ProjectMailer < ApplicationMailer
  def completion_email(manager, project)
    @manager = manager
    @project = project

    mail(
      to: @manager.email,
      subject: "Project Completed: #{@project.title}"
    )
  end
end