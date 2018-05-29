# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"

module Decidim
  module CensusConnector
    module Account
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::CensusConnector::Account

        routes do
          resource :account, only: [:index], as: :account

          root to: "account#index"
        end

        initializer "decidim_census_connector.account.menu" do
          Decidim.menu :user_menu do |menu|
            menu.item I18n.t("menu.census", scope: "decidim.census_connector.account"),
                      decidim_census_account.root_path,
                      position: 1.0,
                      active: :inclusive
          end
        end
      end
    end
  end
end
