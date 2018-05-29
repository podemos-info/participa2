# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"

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
        Decidim.view_hooks.register(:highlighted_elements, priority: Decidim::ViewHooks::MEDIUM_PRIORITY) do |view_context|
          highlighted_collaborations = PersonPrioritizedCollaborations.new(view_context.person_participatory_spaces)

          next unless highlighted_collaborations.any?

          view_context.render(
            partial: "decidim/collaborations/pages/home/highlighted_collaborations",
            locals: {
              highlighted_collaborations: highlighted_collaborations,
              highlighted_collaborations_count: highlighted_collaborations.count
            }
          )
        end
      end
    end
  end
end
