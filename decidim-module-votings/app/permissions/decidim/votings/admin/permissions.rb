# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          # The public part needs to be implemented yet
          return permission_action if permission_action.scope != :admin

          return permission_action if permission_action.subject != :voting

          case permission_action.action
          when :create
            permission_action.allow!
          when :update
            toggle_allow(voting.present?)
          when :destroy
            toggle_allow(can_destroy_voting?)
          end

          permission_action
        end

        private

        def voting
          @voting ||= context.fetch(:voting, nil)
        end

        def can_destroy_voting?
          voting.present? && !voting.started?
        end
      end
    end
  end
end
