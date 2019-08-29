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

      initializer "decidim_crowdfundings.user_menu" do
        Decidim.menu :user_menu do |menu|
          menu.item I18n.t("menu.crowdfundings", scope: "decidim"),
                    decidim_crowdfundings_user_profile.contributions_path,
                    position: 1,
                    active: :inclusive
        end
      end

      initializer "decidim_crowdfundings.register_activism_type" do
        next unless Decidim::Crowdfundings.active?

        Decidim::CensusConnector.register_activism_type(:crowdfunding, order: 10) do |person|
          has_active_contributions = RecurrentContributions.for_user(person.user).merge(ActiveContributions.new).any?

          {
            active: has_active_contributions,
            title: t("decidim.crowdfundings.activism_type.title"),
            status_icon_params: has_active_contributions ? ["check", class: "success"] : ["x", class: "muted"],
            status_text: t("decidim.crowdfundings.activism_type.status.#{has_active_contributions ? :active : :inactive}"),
            edit_link: decidim_crowdfundings_user_profile.contributions_path,
            edit_text: t("decidim.crowdfundings.activism_type.edit")
          }
        end
      end
    end
  end
end
