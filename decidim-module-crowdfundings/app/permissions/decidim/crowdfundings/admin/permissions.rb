# frozen_string_literal: true

module Decidim
  module Crowdfundings
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          # The public part needs to be implemented yet
          return permission_action if permission_action.scope != :admin

          return permission_action if permission_action.subject != :campaign

          case permission_action.action
          when :create
            permission_action.allow!
          when :update, :destroy
            permission_action.allow! if campaign.present?
          end

          permission_action
        end

        private

        def campaign
          @campaign ||= context.fetch(:campaign, nil)
        end
      end
    end
  end
end
