require 'rails_helper'

RSpec.describe Task, type: :model do
  contributor = FactoryBot.create(:contributor)
  project = FactoryBot.create(:project)

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
      contributor_id: '',
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
      project_id: ''
    )

    expect(task).not_to be_valid
    task.project_id = project.id
    expect(task).to be_valid
  end

  it 'has a status' do
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

  it 'has a valid status update transitions' do
    task = Task.create(
      title: 'A title',
      description: 'A valid description.',
      status: 'not_started',
      contributor_id: contributor.id,
      project_id: project.id
    )

    task.update(status: 'in_progress')
    expect(task).to be_valid
    task.update(status: 'completed')
    expect(task).to be_valid
    task.update(status: 'started')
    expect(task).not_to be_valid
    task.update(status: 'in_progress')
    expect(task).not_to be_valid
  end
end
