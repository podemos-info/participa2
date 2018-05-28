# frozen_string_literal: true

module Decidim
  module GravityForms
    module Admin
      # This class holds a Form to create/update gravity forms from Decidim's
      # admin panel.
      class GravityFormForm < Decidim::Form
        include TranslatableAttributes

        translatable_attribute :title, String
        translatable_attribute :description, String

        attribute :slug, String
        attribute :form_number, Integer
        attribute :require_login, Boolean
        attribute :hidden, Boolean

        validates :title, translatable_presence: true
        validates :slug, presence: true, format: { with: /\A[a-zA-Z]+[a-zA-Z0-9\-]+\z/ }
        validates :form_number, presence: true, numericality: { integer: true, greater_than: 0 }
        validates :require_login, inclusion: { in: [true, false] }
        validates :hidden, inclusion: { in: [true, false] }

        validate :slug_uniqueness

        private

        def slug_uniqueness
          return unless GravityForm.where(component: current_component, slug: slug).where.not(id: id).any?

          errors.add(:slug, :taken)
        end
      end
    end
  end
end
