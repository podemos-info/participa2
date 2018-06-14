# frozen_string_literal: true

module Decidim
  module GravityForms
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          # The public part needs to be implemented yet
          return permission_action if permission_action.scope != :admin

          return permission_action if permission_action.subject != :gravity_form

          case permission_action.action
          when :create
            permission_action.allow!
          when :update, :destroy
            permission_action.allow! if gravity_form.present?
          end

          permission_action
        end

        private

        def gravity_form
          @gravity_form ||= context.fetch(:gravity_form, nil)
        end
      end
    end
  end
end
