# frozen_string_literal: true

module Decidim
  module GravityForms
    class GravityForm < ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasComponent

      def to_param
        slug
      end

      def allow_resource_permissions?
        component.settings.resources_permissions_enabled
      end

      def public?
        !require_login && fill_in_permissions.nil?
      end

      private

      def fill_in_permissions
        permissions&.fetch("fill_in", nil) || component.permissions&.fetch("fill_in", nil)
      end
    end
  end
end
