# frozen_string_literal: true

require "rails"
require "active_support/all"
require "decidim/core"
require "cells/rails"
require "cells-erb"
require "cell/partial"

module Decidim
  module Crowdfundings
    # Decidim's Crowdfundings Rails Engine.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Crowdfundings

      routes do
        resources :campaigns, only: [:index, :show] do
          resources :contributions, only: [:create], shallow: true do
            collection do
              post :confirm
            end
            member do
              get :validate
            end
          end
        end

        root to: "campaigns#index"
      end

      initializer "decidim_crowdfundings.assets" do |app|
        app.config.assets.precompile += %w(decidim_crowdfundings_manifest.js)
      end

      initializer "decidim_crowdfundings.view_hooks" do
        Decidim.view_hooks.register(:participatory_space_highlighted_elements, priority: Decidim::ViewHooks::MEDIUM_PRIORITY) do |view_context|
          published_components = Decidim::Component.where(participatory_space: view_context.current_participatory_space).published
          campaigns = Decidim::Crowdfundings::Campaign.active
                                                      .where(component: published_components)
                                                      .limit(Decidim::Crowdfundings.config.participatory_space_highlighted_campaigns_limit)
          next unless campaigns.any?

          view_context.extend Decidim::Crowdfundings::CampaignsHelper
          view_context.render(
            partial: "decidim/participatory_spaces/highlighted_campaigns",
            locals: {
              campaigns: campaigns
            }
          )
        end
      end

      initializer "decidim_crowdfundings.add_cells" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Crowdfundings::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Crowdfundings::Engine.root}/app/views") # for partials
      end
    end
  end
end
