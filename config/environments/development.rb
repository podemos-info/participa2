# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application"s code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don"t have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join("tmp", "caching-dev.txt").exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don"t care if the mailer can"t send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :letter_opener_web

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = false

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  if ENV["TRUSTED_IP"]
    BetterErrors::Middleware.allow_ip! ENV["TRUSTED_IP"]
    config.web_console.whitelisted_ips = [ENV["TRUSTED_IP"], "10.0.0.0/16"]
  end

  # Census Authorization Handler descendants preloading on development environment
  config.eager_load_paths += Dir["app/services/*.rb"]
  ActiveSupport::Reloader.to_prepare do
    Dir["app/services/*.rb"].each { |file| require_dependency file }
  end

  config.logger = ActiveSupport::Logger.new(config.paths["log"].first, 1, 20 * 1024 * 1024)

  I18n::Debug.logger = Logger.new(Rails.root.join("log", "i18n-debug.log"))
end
