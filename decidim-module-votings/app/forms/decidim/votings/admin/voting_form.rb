# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This class holds a Form to create/update votings from
      # Decidim's admin panel.
      class VotingForm < Decidim::Form
        include TranslatableAttributes
        include TranslationsHelper

        translatable_attribute :title, String
        translatable_attribute :description, String

        attribute :start_date, Decidim::Attributes::TimeWithZone
        attribute :end_date, Decidim::Attributes::TimeWithZone
        attribute :image, String
        attribute :decidim_scope_id, Integer
        attribute :importance, Integer
        attribute :voting_system, String
        attribute :voting_domain_name, String
        attribute :voting_identifier, String
        attribute :shared_key, String
        attribute :simulation_code, Integer
        attribute :can_change_shared_key, Boolean
        attribute :change_shared_key, Boolean
        attribute :electoral_districts, Array[ElectoralDistrictForm]

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :image, file_size: { less_than_or_equal_to: ->(_image) { Decidim.maximum_attachment_size } }
        validates :importance, numericality: { only_integer: true }
        validates :start_date, presence: true, date: { before: :end_date }
        validates :end_date, presence: true, date: { after: :start_date }
        validates :simulation_code, numericality: { only_integer: true }
        validates :scope, presence: true, if: ->(form) { form.decidim_scope_id.present? }

        validate :scope_belongs_to_participatory_space_scope
        validate :voting_range_in_process_bounds

        def map_model(voting)
          self.can_change_shared_key = voting.can_change_shared_key?
          self.change_shared_key = false
          self.electoral_districts = voting.electoral_districts.map do |electoral_district|
            ElectoralDistrictForm.from_model(electoral_district)
          end
        end

        # Finds the Scope from the given decidim_scope_id, uses participatory space scope if missing.
        #
        # Returns a Decidim::Scope
        def scope
          @scope ||= @decidim_scope_id ? current_participatory_space.scopes.find_by(id: @decidim_scope_id) : current_participatory_space.scope
        end

        # Scope identifier
        #
        # Returns the scope identifier related to the proposal
        def decidim_scope_id
          @decidim_scope_id || scope&.id
        end

        def simulation_code
          @simulation_code || 0
        end

        def importance
          @importance || 0
        end

        def voting_system
          "nVotes"
        end

        private

        def scope_belongs_to_participatory_space_scope
          errors.add(:decidim_scope_id, :invalid) if current_participatory_space.out_of_scope?(scope)
        end

        # Validates that start_date and end_date are inside participatory process bounds.
        def voting_range_in_process_bounds
          return unless steps?

          errors.add(:start_date, I18n.t("activemodel.errors.voting.voting_range.outside_process_range")) unless included_in_steps?(start_date)

          errors.add(:end_date, I18n.t("activemodel.errors.voting.voting_range.outside_process_range")) unless included_in_steps?(end_date)
        end

        def included_in_steps?(date_time)
          return true if date_time.blank?

          steps_containing_date = steps.select do |step|
            date_time.between?(step.start_date, step.end_date)
          end
          steps.empty? || steps_containing_date.any?
        end

        def steps?
          current_participatory_space.respond_to? :steps
        end

        def steps
          current_participatory_space.steps
        end
      end
    end
  end
end
