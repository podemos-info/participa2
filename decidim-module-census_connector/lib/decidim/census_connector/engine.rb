# frozen_string_literal: true

require "rails"
require "active_support/all"
require "hutch"

require "decidim/core"

module Decidim
  module CensusConnector
    # Decidim's CensusConnector Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::CensusConnector

      config.eager_load_paths << File.expand_path("app/consumers/**", __dir__)

      initializer "decidim_census_connector.consumers_paths" do
        consumers_paths = "#{config.root}/app/consumers/**/*.rb"
        ActiveSupport::Reloader.to_prepare do
          Dir[consumers_paths].each { |file| require_dependency file }
        end
      end

      initializer "decidim_census_connector.assets" do |app|
        app.config.assets.precompile += %w(decidim_census_connector_manifest.js decidim_census_connector_manifest.css)
      end

      initializer "decidim_census_connector.mount_routes" do
        Decidim.register_global_engine "decidim_census_account", Decidim::CensusConnector::Account::Engine, at: "census_account"
      end

      def load_seed
        Decidim::Scope.delete_all
        Decidim::ScopeType.delete_all

        Decidim::Organization.find_each do |organization|
          Decidim::CensusConnector::Seeds::Scopes.new(organization).seed
        end
      end
    end
  end
end
