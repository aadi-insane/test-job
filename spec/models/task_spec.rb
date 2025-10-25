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
        due_date: Date.today,
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
        due_date: Date.today,
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
        due_date: Date.today,
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
        due_date: Date.today,
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
        due_date: Date.today,
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

    it 'has a valid due date' do
      task = Task.new(
        title: 'A title',
        description: 'A valid description.',
        status: 'not_started',
        due_date: '',
        contributor_id: contributor.id,
        project_id: project.id
      )
      expect(task).not_to be_valid

      task.due_date = Date.today
      expect(task).to be_valid
    end
  end

  describe 'status transitions' do
    let(:contributor) { create(:contributor) }
    let(:task) { create(:task, contributor_id: contributor.id) }

    context 'when the status is not_started' do
      it 'can transition to in_progress' do
        expect(task.status).to eq('not_started')
        task.start!
        expect(task.status).to eq('in_progress')
      end

      it 'cannot transition directly to completed' do
        expect { task.complete! }.to raise_error(AASM::InvalidTransition)
      end
    end

    context 'when the status is in_progress' do
      before { task.start! }

      it 'can transition to completed' do
        allow(task).to receive(:dependencies_completed?).and_return(true)
        task.complete!
        expect(task.status).to eq('completed')
      end

      it 'cannot transition to not_started' do
        expect { task.start! }.to raise_error(AASM::InvalidTransition)
      end
    end

    context 'when the status is completed' do
      before do
        task.start!
        allow(task).to receive(:dependencies_completed?).and_return(true)
        task.complete!
      end

      it 'cannot transition to in_progress' do
        expect { task.start! }.to raise_error(AASM::InvalidTransition)
      end

      it 'cannot transition to not_started' do
        expect { task.start! }.to raise_error(AASM::InvalidTransition)
      end
    end
  end

end
