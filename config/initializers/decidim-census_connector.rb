# frozen_string_literal: true

Decidim::CensusConnector.configure do |config|
  config.census_api_debug = true
  config.census_api_base_uri = ENV["CENSUS_URL"]
end
