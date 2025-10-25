require 'csv'

class BulkTaskImporterWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options queue: 'bulk_import', retry: 3, unique: :until_executed

  def perform(csv_path, project_id)
    project = Project.find_by(id: project_id)
    return unless project && File.exist?(csv_path)

    CSV.foreach(csv_path, headers: true) do |row|
      task_data = row.to_h
      CreateTaskWorker.perform_async(task_data, project.id)
    end
  end
end

class CreateTaskWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'bulk_import', retry: 2, unique: :until_executed

  def perform(task_data, project_id)
    project = Project.find_by(id: project_id)
    return unless project
    project.tasks.create!(task_data)
  end
end
