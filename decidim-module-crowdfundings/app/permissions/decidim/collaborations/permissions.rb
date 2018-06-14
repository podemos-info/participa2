# frozen_string_literal: true

module Decidim
  module Collaborations
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Collaborations::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        return permission_action if permission_action.scope != :public

        allowed_collaboration_action?
        allowed_user_collaboration_action?

        permission_action
      end

      private

      def collaboration
        @collaboration ||= context.fetch(:collaboration, nil)
      end

      def user_collaboration
        @user_collaboration ||= context.fetch(:user_collaboration, nil)
      end

      def current_settings
        @current_settings ||= context.fetch(:current_settings, nil)
      end

      def allowed_collaboration_action?
        return unless permission_action.subject == :collaboration

        case permission_action.action
        when :support
          toggle_allow(
            collaboration.accepts_supports? &&
            current_settings.collaborations_allowed? &&
            under_collaboration_limit?
          )
        when :support_recurrently
          toggle_allow(
            collaboration.recurrent_support_allowed? &&
            collaboration.user_collaborations.recurrent.supported_by(user).none?
          )
        end
      end

      def allowed_user_collaboration_action?
        return unless permission_action.subject == :user_collaboration

        case permission_action.action
        when :update
          toggle_allow(
            user_collaboration.user.id == user.id &&
            user_collaboration.recurrent? &&
            user_collaboration.accepted?
          )
        when :resume
          toggle_allow(
            user_collaboration.user.id == user.id &&
            user_collaboration.recurrent? &&
            user_collaboration.paused?
          )
        end
      end

      def under_collaboration_limit?
        user_totals = Census::API::Totals.user_totals(user.id)

        user_totals && user_totals < Decidim::Collaborations.maximum_annual_collaboration
      end
    end
  end
end
