# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"

module Decidim
  module Votings
    # Decidim's <EngineName> Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Votings

      # TODO: Repace this by global routes feature that will be released in decidim 0.8.1
      initializer "decidim_votings_confirmations.mount_routes" do |_app|
        Decidim::Core::Engine.routes do
          mount Decidim::Votings::VoteConfirmationEngine => "/confirmations"
        end
      end

      routes do
        resources :votings, only: [:index, :show] do
          get :token
          resource :vote, only: [:show] do
            get :token
          end
        end

        root to: "votings#index"
      end

      initializer "decidim_votings.assets" do |app|
        app.config.assets.precompile += %w(decidim_votings_manifest.js decidim_votings_manifest.css)
      end

      initializer "decidim_votings.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.abilities += ["Decidim::Votings::Abilities::CurrentUserAbility"]
        end
      end
    end
  end
end
