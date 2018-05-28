# frozen_string_literal: true

module Decidim
  module Collaborations
    module Admin
      # This class holds a Form to create/update collaborations from
      # Decidim's admin panel.
      class CollaborationForm < Decidim::Form
        include TranslatableAttributes
        include TranslationsHelper

        translatable_attribute :title, String
        translatable_attribute :description, String
        translatable_attribute :terms_and_conditions, String

        attribute :default_amount, Integer
        attribute :minimum_custom_amount, Integer
        attribute :target_amount, Integer
        attribute :active_until, Date
        attribute :amounts, String

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :terms_and_conditions, translatable_presence: true

        validates :amounts, presence: true

        validates :default_amount,
                  presence: true,
                  numericality: { only_integer: true, greater_than: 0 }

        validates :minimum_custom_amount,
                  presence: true,
                  numericality: { only_integer: true, greater_than: 0 }

        validates :target_amount,
                  numericality: { only_integer: true, greater_than: 0 },
                  allow_blank: true

        validate :amounts_consistency

        validate :active_until_in_process_bounds,
                 unless: proc { |form| form.active_until.blank? }

        def map_model(collaboration)
          self.amounts = collaboration.amounts&.join(", ")
        end

        private

        def amounts_consistency
          return if value_list?(amounts)

          errors.add(
            :amounts,
            I18n.t(
              "amounts.invalid_format",
              scope: "activemodel.errors.models.collaboration.attributes"
            )
          )
        end

        def value_list?(value)
          /^\s*\d+\s*(,\s*\d+\s*)*$/.match?(value)
        end

        # Validates that active until is inside participatory process bounds.
        def active_until_in_process_bounds
          return unless steps?
          return if included_in_steps?(active_until)

          errors.add(
            :active_until,
            I18n.t(
              "active_until.outside_process_range",
              scope: "activemodel.errors.models.collaboration.attributes"
            )
          )
        end

        def included_in_steps?(date)
          steps_containing_date = steps.select do |step|
            step_range = step.start_date..step.end_date
            step_range.include? date
          end
          steps_containing_date.any?
        end

        def steps?
          context.current_component.participatory_space.respond_to? :steps
        end

        def steps
          context.current_component.participatory_space.steps
        end
      end
    end
  end
end
