# config/initializers/sidekiq.rb

# =========================================
# Local Development (default)
# =========================================
redis_url = ENV.fetch('REDIS_URL', 'redis://127.0.0.1:6379/0')

Sidekiq.configure_server do |config|
  config.redis = {
    url: redis_url,
    size: 10,
    pool_name: 'internal'
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: redis_url,
    size: 5,
    pool_name: 'default'
  }
end

# =========================================
# Docker (uncomment when running in Docker)
# =========================================
# redis_url = ENV.fetch('REDIS_URL', 'redis://redis:6379/0')
#
# Sidekiq.configure_server do |config|
#   config.redis = {
#     url: redis_url,
#     size: 10,
#     pool_name: 'internal'
#   }
# end
#
# Sidekiq.configure_client do |config|
#   config.redis = {
#     url: redis_url,
#     size: 5,
#     pool_name: 'default'
#   }
# end
