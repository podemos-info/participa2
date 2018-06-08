# frozen_string_literal: true

module Decidim
  module GravityForms
    class GravityForm < ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasComponent

      def to_param
        slug
      end
    end
  end
end
