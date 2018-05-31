# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"
require "cells/rails"
require "cells-erb"
require "cell/partial"

module Decidim
  module Collaborations
    # Decidim's Collaborations Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Collaborations

      # TODO: Repace this by global routes feature that will be released in decidim 0.8.1
      initializer "decidim_collaborations_user_profile.mount_routes" do |_app|
        Decidim::Core::Engine.routes do
          mount Decidim::Collaborations::UserProfileEngine => "/collaborations"
        end
      end

      routes do
        resources :collaborations, only: [:index, :show] do
          resources :user_collaborations, only: [:create], shallow: true do
            collection do
              post :confirm
            end
            member do
              get :validate
            end
          end
        end

        root to: "collaborations#index"
      end

      initializer "decidim_collaborations.inject_abilities_to_user" do |_app|
        Decidim.configure do |config|
          config.abilities += %w(
            Decidim::Collaborations::Abilities::CurrentUserAbility
            Decidim::Collaborations::Abilities::GuestUserAbility
          )
        end
      end

      initializer "decidim_collaborations.assets" do |app|
        app.config.assets.precompile += %w(decidim_collaborations_manifest.js)
      end

      initializer "decidim_collaborations.view_hooks" do
        Decidim.view_hooks.register(:participatory_space_highlighted_elements, priority: Decidim::ViewHooks::MEDIUM_PRIORITY) do |view_context|
          published_components = Decidim::Component.where(participatory_space: view_context.current_participatory_space).published
          collaborations = Decidim::Collaborations::Collaboration.active
                                                                 .where(component: published_components)
                                                                 .limit(Decidim::Collaborations.config.participatory_space_highlighted_collaborations_limit)
          next unless collaborations.any?

          view_context.extend Decidim::Collaborations::CollaborationsHelper
          view_context.render(
            partial: "decidim/participatory_spaces/highlighted_collaborations",
            locals: {
              collaborations: collaborations
            }
          )
        end
      end

      initializer "decidim_collaborations.add_cells" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Collaborations::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Collaborations::Engine.root}/app/views") # for partials
      end
    end
  end
end
