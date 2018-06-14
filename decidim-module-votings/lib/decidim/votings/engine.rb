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

      initializer "decidim_votings.view_hooks" do
        Decidim.view_hooks.register(:participatory_space_highlighted_elements, priority: Decidim::ViewHooks::HIGH_PRIORITY) do |view_context|
          published_components = Decidim::Component.where(participatory_space: view_context.current_participatory_space).published
          votings = Decidim::Votings::Voting.active
                                            .where(component: published_components)
                                            .limit(Decidim::Votings.config.participatory_space_highlighted_voting_limit)
          next unless votings.any?

          view_context.extend Decidim::Votings::VotingsHelper
          view_context.render(
            partial: "decidim/participatory_spaces/highlighted_votings",
            locals: {
              votings: votings
            }
          )
        end
      end

      initializer "decidim_votings.add_cells" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Votings::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Votings::Engine.root}/app/views") # for partials
      end
    end
  end
end
