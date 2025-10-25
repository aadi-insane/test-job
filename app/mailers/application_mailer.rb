class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@projectmanager.com"
  layout "mailer"
end