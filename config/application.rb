require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CsPrepaidApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.time_zone = "Pacific Time (US & Canada)"

    # Don't generate system test files.
    config.generators.system_tests = nil
    config.active_job.queue_adapter = :resque
  end
end
