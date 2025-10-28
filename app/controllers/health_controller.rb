class HealthController < ApplicationController
  def show
    # For checking Database 
    ActiveRecord::Base.connection.execute("SELECT 1")

    # redis_url = Rails.application.credentials.dig(:redis, :url)
    redis_url = ENV['REDIS_URL']
    redis = Redis.new(url: redis_url)
    raise "Redis not reachable" unless redis.ping == "PONG"

    render json: { status: "ok" }, status: :ok
  rescue => e
    render json: { status: "error", message: e.message }, status: :service_unavailable
  end
end
