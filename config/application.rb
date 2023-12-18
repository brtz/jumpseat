# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

if ["development"].include? ENV["RAILS_ENV"]
  begin
    Dotenv::Railtie.load
  rescue
    puts "Failed to load .env"
  end
end

module Jumpseat
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.active_record.encryption.extend_queries = true

    config.active_record.encryption.primary_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY")
    config.active_record.encryption.deterministic_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY")
    config.active_record.encryption.key_derivation_salt = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT")

    config.active_record.async_query_executor = :global_thread_pool
    config.active_record.global_executor_concurrency = ENV.fetch("RAILS_MAX_THREADS") { 5 }

    config.active_job.queue_adapter = :sidekiq

    config.hosts = [] + ENV.fetch("RAILS_HOSTS").split(",").map(&:strip)

    config.cache_store = :redis_cache_store, { url: ENV["REDISCLOUD_URL"] }
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.after_initialize do
      ReservationsCleanupJob.perform_later
      LimitationsCleanupJob.perform_later
    end
  end
end
