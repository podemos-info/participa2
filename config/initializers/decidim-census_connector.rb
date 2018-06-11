# frozen_string_literal: true

Decidim::CensusConnector.configure do |config|
  config.census_api_debug = Rails.application.secrets.census[:api_debug]
  config.census_api_base_uri = Rails.application.secrets.census[:api_base_uri]
end
