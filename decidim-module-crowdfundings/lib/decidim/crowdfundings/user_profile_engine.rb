# frozen_string_literal: true

require "decidim/core"

module Decidim
  module Crowdfundings
    # This is the engine that runs on the public interface of
    # `decidim-crowdfundings`. It mostly handles rendering
    # the crowdfundings campaigns associated to aDecidim participatory space.
    class UserProfileEngine < ::Rails::Engine
      isolate_namespace Decidim::Crowdfundings::UserProfile

      paths["db/migrate"] = nil

      routes do
        resources :contributions, only: [:index, :edit, :update] do
          member do
            get "pause"
            get "resume"
          end
        end

        root to: "contributions#index"
      end
    end
  end
end

Decidim.register_global_engine(:decidim_crowdfundings_user_profile, Decidim::Crowdfundings::UserProfileEngine, at: "/crowdfundings")
