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
    end
  end
end
