# frozen_string_literal: true

module Decidim
  module CensusConnector
    class Person
      include Census::API::PersonDefinitions
      delegate :id, to: :scope, prefix: true
      delegate :id, to: :address_scope, prefix: true
      delegate :id, to: :document_scope, prefix: true

      def initialize(person_data, &block)
        @person_data = person_data
        @defer_person_data = block if block_given?
      end

      PERSON_ATTRIBUTES.each do |attribute|
        method_name = attribute == "born_at" ? "_#{attribute}" : attribute

        define_method method_name do
          load_deferred_person_data unless person_data.has_key?(attribute)
          person_data[attribute]
        end
      end

      {
        state: STATES,
        verification: VERIFICATIONS,
        membership_level: MEMBERSHIP_LEVELS
      }.each do |attribute, values|
        values.each do |value|
          define_method "#{value}?" do
            send(attribute) == value
          end
        end
      end

      def born_at
        @born_at ||= Date.parse(_born_at) if _born_at.present?
      end

      def scope
        @scope ||= Decidim::Scope.find_by(code: scope_code)
      end

      def address_scope
        @address_scope ||= Decidim::Scope.find_by(code: address_scope_code)
      end

      def document_scope
        @document_scope ||= Decidim::Scope.find_by(code: document_scope_code)
      end

      def age
        @age ||= born_at ? calculate_age : 0
      end

      def load_deferred_person_data
        @person_data = deferred_person_data if deferred_person_data
      end

      private

      attr_reader :person_data, :defer_person_data

      def deferred_person_data
        return @deferred_person_data if defined?(@deferred_person_data)
        @deferred_person_data = defer_person_data.call.stringify_keys.tap { @defer_person_data = nil } unless defer_person_data.nil?
      end

      def calculate_age
        now = Time.zone.now.to_date

        this_year = now.year
        this_month = now.month
        today = now.day

        birth_year = born_at.year
        birth_month = born_at.month
        birth_day = born_at.day

        month_of_birth_passed = this_month > birth_month
        month_of_birth_current_but_day_passed = this_month == birth_month && today >= birth_day

        this_year - birth_year - (month_of_birth_passed || month_of_birth_current_but_day_passed ? 0 : 1)
      end
    end
  end
end
