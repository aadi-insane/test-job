require 'rails_helper'

RSpec.describe DependencyMailer, type: :mailer do
  describe 'unblock_notification' do
    let!(:manager) { create(:manager) }
    let!(:contributor) { create(:contributor) }
    let!(:task1) { create(:task, status: :completed, user_as_contributor: manager) }
    let!(:task2) { create(:task, status: :not_started, user_as_contributor: contributor) }

    before do
      create(:task_dependency, task: task1, dependent_task: task2)
    end

    it 'sends unblock notification email' do
      mail = DependencyMailer.unblock_notification(contributor, task1, task2)
      expect(mail.subject).to include("Your task is now unblocked: #{task2.title}")
      expect(mail.to).to eq([contributor.email])
      expect(mail.body.encoded).to include(task2.title)
    end
  end
end
