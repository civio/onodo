require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsRectTest
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :es
    config.i18n.available_locales = [:en, :es]

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # ActionMailer config
    config.action_mailer.default_url_options = { host: ENV['HOST'] }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
        address: 'smtp.sendgrid.net',
        port: 587,
        domain: ENV['MAILER_DOMAIN'],
        authentication: 'plain',
        enable_starttls_auto: true,
        user_name: ENV['MAILER_USERNAME'],
        password: ENV['MAILER_PASSWORD']
    }

    # Webpack integrations
    config.webpack.dev_server.enabled = false
    config.webpack.output_dir = "#{Rails.root}/public/webpack"
    config.webpack.manifest_filename = "manifest.json"

    # Disable IP spoofing check
    config.action_dispatch.ip_spoofing_check = false
  end
end
