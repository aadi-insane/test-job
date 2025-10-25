# app/workers/idempotent_job_worker.rb
class IdempotentJobWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options queue: 'idempotent_jobs', retry: 5, unique: :until_executed

  def perform(unique_key)
    return if Rails.cache.exist?(unique_key)
    if defined?(SomeService)
      SomeService.safe_operation
      Rails.cache.write(unique_key, true, expires_in: 24.hours)
    else
      Rails.logger.error "SomeService not defined!"
    end
  end
end
