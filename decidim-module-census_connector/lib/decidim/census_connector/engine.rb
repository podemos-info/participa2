# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"

module Decidim
  module CensusConnector
    # Decidim's CensusConnector Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::CensusConnector

      initializer "decidim_census_conector.inject_abilities_to_user" do
        Decidim.configure do |config|
          config.abilities += ["Decidim::CensusConnector::Verifications::Abilities::CurrentUserAbility"]
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
