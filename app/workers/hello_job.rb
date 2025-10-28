require 'sidekiq'

class HelloJob
  include Sidekiq::Job

  def perform
    puts "Hello from inside a background job!"
  end
end

# puts "hello from outside the job"

# HelloJob.perform_in(60)

# puts "hello from after the job"

# Methods related to background jobs in Sidekiq
# perform
# perform_async
# perform_in
# perform_at
# perform_later  # This is framework-agnostic Rails method

# command to start sidekiq
# bundle exec sidekiq -e development -C config/sidekiq.yml

# command to start docker console
# docker compose exec web bash