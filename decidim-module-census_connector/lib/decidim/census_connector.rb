# frozen_string_literal: true

require "decidim/census_connector/version"
require "decidim/census_connector/engine"
require "decidim/census_connector/railtie" if defined?(Rails)
require "decidim/census_connector/account/engine"

require "decidim/census_connector/verifications/census"

module Decidim
  # Base module for this engine.
  module CensusConnector
    autoload :ActivismTypeRegistry, "decidim/activism_type_registry"

    include ActiveSupport::Configurable

    config_accessor :census_local_code do
      "ES"
    end

    config_accessor :census_non_local_code do
      "XX"
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

    # Public: Register a type of activism in the registry
    def self.register_activism_type(name, order: 0, &block)
      activism_types.register_activism_type(name, order: order, &block)
    end

    # Public: Stores an instance of ActivismTypesRegistry
    def self.activism_types
      @activism_types ||= ActivismTypeRegistry.new
    end

    def self.social_networks
      @social_networks ||= {
        facebook: {
          name: "Facebook",
          url: "https://www.facebook.com/%{nickname}",
          nickname_validation: /^([a-zA-Z\d.]{5,})$/
        },
        twitter: {
          name: "Twitter",
          url: "https://twitter.com/%{nickname}",
          nickname_validation: /^@?(\w{1,15})$/
        }
      }
    end

    def self.register_social_network(handle, name:, url:, nickname_validation:)
      social_networks[handle] = { name: name, url: url, nickname_validation: nickname_validation }
    end

    def self.unregister_social_network(handle)
      social_networks.delete handle
    end
  end
end
