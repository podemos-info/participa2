# frozen_string_literal: true

Airbrake.configure do |config|
  config.environment = Rails.env
  config.ignore_environments = %w(test development)
  config.host = Rails.application.secrets.airbrake[:host]
  config.project_id = Rails.application.secrets.airbrake[:project_id]
  config.project_key = Rails.application.secrets.airbrake[:api_key]
  config.root_directory = Rails.root
  config.logger = Rails.logger
  config.blacklist_keys = Rails.application.config.filter_parameters
end
