# frozen_string_literal: true

module Decidim
  module Crowdfundings
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Crowdfundings::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        return permission_action if permission_action.scope != :public

        allowed_campaign_action?
        allowed_contribution_action?

        permission_action
      end

      private

      def campaign
        @campaign ||= context.fetch(:campaign, nil)
      end

      def contribution
        @contribution ||= context.fetch(:contribution, nil)
      end

      def current_settings
        @current_settings ||= context.fetch(:current_settings, nil)
      end

      def allowed_campaign_action?
        return unless permission_action.subject == :campaign

        case permission_action.action
        when :support
          toggle_allow(
            campaign.accepts_supports? &&
            current_settings.contribution_allowed? &&
            campaign.under_annual_limit?(user)
          )
        when :support_recurrently
          toggle_allow(
            campaign.recurrent_support_allowed? &&
            campaign.contributions.recurrent.supported_by(user).none?
          )
        end
      end

      def allowed_contribution_action?
        return unless permission_action.subject == :contribution

        case permission_action.action
        when :update
          toggle_allow(
            contribution.user.id == user.id &&
            contribution.recurrent? &&
            contribution.accepted?
          )
        when :resume
          toggle_allow(
            contribution.user.id == user.id &&
            contribution.recurrent? &&
            contribution.paused?
          )
        end
      end
    end
  end
end
