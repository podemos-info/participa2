# frozen_string_literal: true

require "decidim/core"

module Decidim
  module Collaborations
    # This is the engine that runs on the public interface of
    # `decidim-collaborations`. It mostly handles rendering
    # the collaborations associated to a participatory Decidimprocess.
    class UserProfileEngine < ::Rails::Engine
      isolate_namespace Decidim::Collaborations::UserProfile

      paths["db/migrate"] = nil

      routes do
        resources :user_collaborations, only: [:index, :edit, :update] do
          member do
            get "pause"
            get "resume"
          end
        end

        root to: "user_collaborations#index"
      end

      initializer "decidim_collaborations.user_menu" do
        Decidim.menu :user_menu do |menu|
          menu.item I18n.t("menu.collaborations", scope: "decidim"),
                    decidim_collaborations_user_profile.user_collaborations_path,
                    position: 2,
                    active: :inclusive
        end
      end
    end
  end
end
