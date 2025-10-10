require 'rails_helper'

RSpec.describe Project, type: :model do
  manager = FactoryBot.create(:manager)

  it 'has a title' do
    project = Project.new(
      title: '',
      description: 'A valid description.',
      status: 'active',
      manager_id: manager.id
    )

    expect(project).not_to be_valid
    project.title = "A title"
    expect(project).to be_valid
  end
  it 'has a description' do
    project = Project.new(
      title: 'A title',
      description: '',
      status: 'active',
      manager_id: manager.id
    )
    
    expect(project).to be_valid
  end
  it 'has a manager_id' do
    project = Project.new(
      title: 'A title',
      description: 'A valid description.',
      status: 'active',
      manager_id: ''
    )

    expect(project).not_to be_valid
    project.manager_id = manager.id
    expect(project).to be_valid
  end
  it 'has a status' do
    project = Project.new(
      title: 'A title',
      description: 'A valid description.',
      status: 'random_status',
      manager_id: manager.id
    )

    expect(project).not_to be_valid
    project.status = 'active'
    expect(project).to be_valid
    project.status = 'inactive'
    expect(project).to be_valid
    project.status = 'completed'
    expect(project).to be_valid
  end
end
