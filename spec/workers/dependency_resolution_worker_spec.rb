require 'rails_helper'

RSpec.describe DependencyResolutionWorker, type: :worker do
  # let!(:manager) { create(:manager) }
  let!(:contributor) { create(:contributor) }
  let!(:project) { create(:project) }

  let!(:task1) { create(:task, status: :not_started, user_as_contributor: contributor, project: project) }
  let!(:task2) { create(:task, status: :not_started, user_as_contributor: contributor, project: project) }
  let!(:task3) { create(:task, status: :not_started, user_as_contributor: contributor, project: project) }

  before do
    create(:task_dependency, task: task1, dependent_task: task2)
    create(:task_dependency, task: task1, dependent_task: task3)
  end

  describe '#perform' do
    context 'when task is completed and dependent tasks exist' do
      it 'does not allow dependent tasks to be completed before task1' do
        expect(task2.reload.dependencies_completed?).to be_falsey
        expect(task3.reload.dependencies_completed?).to be_falsey

        task2.update(status: :completed)
        task3.update(status: :completed)

        expect(task2.reload.status).to eq('not_started')
        expect(task3.reload.status).to eq('not_started')
      end

      it 'updates dependent tasks to completed after task1 is completed' do
        task1.update(status: :completed)

        DependencyResolutionWorker.new.perform(task1.id)

        expect(task2.reload.dependencies_completed?).to be_truthy
        expect(task3.reload.dependencies_completed?).to be_truthy

        expect(task2.reload.status).to eq('completed')
        expect(task3.reload.status).to eq('completed')
      end

      it 'sends unblock notification email to the user' do
        task1.update(status: :completed)

        allow(DependencyMailer).to receive(:unblock_notification).and_call_original

        DependencyResolutionWorker.new.perform(task1.id)

        expect(DependencyMailer).to have_received(:unblock_notification).with(task2.user_as_contributor, task1, task2)
      end
    end

    context 'when prerequisites are not completed' do
      it 'does not unblock dependent tasks' do
        task1.update(status: :in_progress)

        DependencyResolutionWorker.new.perform(task1.id)

        expect(task2.reload.dependencies_completed?).to be_falsey
        expect(task3.reload.dependencies_completed?).to be_falsey
      end
    end
  end
end
