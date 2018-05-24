# frozen_string_literal: true

require "decidim/census_connector/version"
require "decidim/census_connector/engine"
require "decidim/census_connector/railtie" if defined?(Rails)
require "decidim/census_connector/account/engine"

require "decidim/census_connector/verifications/census"

module Decidim
  # Base module for this engine.
  module CensusConnector
    include ActiveSupport::Configurable

    config_accessor :census_local_code do
      "ES"
    end

    config_accessor :person_minimum_age do
      14
    end

    # Entry point for Census API
    config_accessor :census_api_base_uri do
      "https://census.example.org"
    end

    # IP address for the proxy used to access to the Census API
    config_accessor :census_api_proxy_address do
      nil
    end

    # Port used for the proxy used to access to the Census API
    config_accessor :census_api_proxy_port do
      nil
    end

    # Enable debug output in the logs for the communication with
    # Census API.
    config_accessor :census_api_debug do
      false
    end
  end
end
