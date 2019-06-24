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

      initializer "register social networks activism type" do
        Decidim::CensusConnector.register_activism_type(:social_networks, order: 100) do |person|
          social_networks = Decidim::CensusConnector.social_networks.map do |social_network, info|
            info[:name] if person.additional_information[:"social_network_#{social_network}"].present?
          end.compact

          active = social_networks.any?

          {
            active: active,
            title: t("social_networks.activism_type.title", scope: "decidim.census_connector.account"),
            status_icon_params: active ? ["check", class: "success"] : ["x", class: "muted"],
            status_text: active ? social_networks.to_sentence : t("social_networks.activism_type.inactive", scope: "decidim.census_connector.account"),
            edit_link: decidim_census_account.social_networks_path,
            edit_text: t("social_networks.activism_type.modify", scope: "decidim.census_connector.account")
          }
        end
      end

      # UPDATABLE: Fix 0.17.1 typo bug (fixed in #5168)
      initializer "fix decidim typo" do
        Decidim::ActionAuthorizer.class_eval do
          def authorization_handlers
            if permission&.has_key?("authorization_handler_name")
              opts = permission["options"]
              { permission["authorization_handler_name"] => opts.present? ? { "options" => opts } : {} }
            else
              permission&.fetch("authorization_handlers", {})
            end
          end
        end
      end
    end
  end
end
