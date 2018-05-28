# frozen_string_literal: true

require "active_support/concern"

module Census
  module API
    # Container module for Census API constants
    module Definitions
      extend ActiveSupport::Concern

      DOCUMENT_TYPES = %w(dni nie passport).freeze
      GENDERS = %w(female male other undisclosed).freeze
      MEMBERSHIP_LEVELS = %w(follower member).freeze
      STATES = %w(pending enabled cancelled trashed).freeze
      VERIFICATIONS = %w(not_verified verification_requested verified mistake fraudulent).freeze

      class_methods do
        def document_types
          @document_types ||= Hash[DOCUMENT_TYPES.map { |type| [I18n.t("census.api.person.document_type.#{type}"), type] }].freeze
        end

        def genders
          @genders ||= Hash[GENDERS.map { |gender| [I18n.t("census.api.person.gender.#{gender}"), gender] }].freeze
        end

        def membership_levels
          @membership_levels ||= Hash[MEMBERSHIP_LEVELS.map do |membership_level|
            [I18n.t("census.api.person.membership_level.#{membership_level}"), membership_level]
          end].freeze
        end

        def local_document?(document_type)
          document_type != "passport"
        end
      end
    end
  end
end
