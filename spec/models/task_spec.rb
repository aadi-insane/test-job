require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:contributor) { FactoryBot.create(:contributor) }
  let(:project) { FactoryBot.create(:project) }

  describe 'validations' do
    it 'has a title' do
      task = Task.new(
        title: '',
        description: 'A valid description.',
        status: 'not_started',
        contributor_id: contributor.id,
        project_id: project.id
      )
      expect(task).not_to be_valid
      task.title = "A title"
      expect(task).to be_valid
    end

    it 'has a description' do
      task = Task.new(
        title: 'A title',
        description: '',
        status: 'not_started',
        contributor_id: contributor.id,
        project_id: project.id
      )
      expect(task).to be_valid
    end

    it 'has a contributor_id' do
      task = Task.new(
        title: 'A title',
        description: 'A valid description.',
        status: 'not_started',
        contributor_id: nil,
        project_id: project.id
      )
      expect(task).not_to be_valid
      task.contributor_id = contributor.id
      expect(task).to be_valid
    end

    it 'has a project_id' do
      task = Task.new(
        title: 'A title',
        description: 'A valid description.',
        status: 'not_started',
        contributor_id: contributor.id,
        project_id: nil
      )
      expect(task).not_to be_valid
      task.project_id = project.id
      expect(task).to be_valid
    end

    it 'has a valid status' do
      task = Task.new(
        title: 'A title',
        description: 'A valid description.',
        status: 'random_status',
        contributor_id: contributor.id,
        project_id: project.id
      )
      expect(task).not_to be_valid

      task.status = 'not_started'
      expect(task).to be_valid

      task.status = 'in_progress'
      expect(task).to be_valid

      task.status = 'completed'
      expect(task).to be_valid
    end
  end

  describe 'status transitions' do
    let(:task) { FactoryBot.create(:task) }

    it 'allows valid transitions by updating status directly' do
      task.update!(status: 'in_progress')
      expect(task.reload.status).to eq('in_progress')

      task.update!(status: 'completed')
      expect(task.reload.status).to eq('completed')
    end

    it 'allows same status update' do
      expect(task.update(status: 'not_started')).to be true
      expect(task.errors).to be_empty
    end

    it 'prevents invalid transition: completed to in_progress' do
      task.update!(status: 'completed')
      expect {
        task.update!(status: 'in_progress')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'prevents unknown status update' do
      expect {
        task.update!(status: 'random_status')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
