# frozen_string_literal: true

module Decidim
  module GravityForms
    class Permissions < Decidim::DefaultPermissions
      def permissions
        # Delegate the admin permission checks to the admin permissions class
        return Decidim::GravityForms::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        return permission_action if permission_action.scope != :public

        return permission_action if permission_action.subject != :gravity_form

        case permission_action.action
        when :fill_in
          toggle_allow(can_fill_in?)
        end

        permission_action
      end

      private

      def can_fill_in?
        authorized?(:fill_in, resource: gravity_form)
      end

      def gravity_form
        @gravity_form ||= context.fetch(:gravity_form, nil)
      end
    end
  end
end
