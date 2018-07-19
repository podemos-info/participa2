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
          toggle_allow(can_vote?)
        when :simulate_vote
          toggle_allow(can_simulate_vote?)
        end

        permission_action
      end

      private

      def can_vote?
        !voting.finished? && authorized?(:vote, resource: voting)
      end

      def can_simulate_vote?
        !voting.started?
      end

      def voting
        @voting ||= context.fetch(:voting, nil)
      end
    end
  end
end
