# frozen_string_literal: true

module Decidim
  module Votings
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Votings::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        return permission_action if permission_action.subject != :voting

        case permission_action.action
        when :vote
          permission_action.allow! if can_vote?
        end

        permission_action
      end

      private

      def can_vote?
        voting.started? && !voting.finished? && (
          component_settings.remote_authorization_url.blank? ||
          Decidim::Votings::RemoteAuthorizer.new(component_settings.remote_authorization_url).authorized?(user, voting)
        )
      end

      def voting
        @voting ||= context.fetch(:voting, nil)
      end
    end
  end
end
