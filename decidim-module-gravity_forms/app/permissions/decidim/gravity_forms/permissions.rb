# frozen_string_literal: true

module Decidim
  module GravityForms
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::GravityForms::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        return permission_action if permission_action.subject != :gravity_form

        case permission_action.action
        when :answer
          permission_action.allow!
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
