# frozen_string_literal: true

module Decidim
  module Collaborations
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          # The public part needs to be implemented yet
          return permission_action if permission_action.scope != :admin

          return permission_action if permission_action.subject != :collaboration

          case permission_action.action
          when :create
            permission_action.allow!
          when :update, :destroy
            permission_action.allow! if collaboration.present?
          end

          permission_action
        end

        private

        def collaboration
          @collaboration ||= context.fetch(:collaboration, nil)
        end
      end
    end
  end
end
