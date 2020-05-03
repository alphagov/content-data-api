require_relative "boot"

require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "active_job/railtie"
require "active_model/railtie"
require "active_record/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative "raven"

module ContentPerformanceManager
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.active_job.queue_adapter = :sidekiq

    additional_paths = %W[#{config.root}/lib #{config.root}/app/domain]

    config.autoload_paths += additional_paths
    config.eager_load_paths += additional_paths
  end
end
