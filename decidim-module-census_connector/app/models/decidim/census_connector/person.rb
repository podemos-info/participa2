# frozen_string_literal: true

module Decidim
  module CensusConnector
    class Person
      include Census::API::Definitions

      delegate :first_name, :last_name1, :last_name2, to: :person_data
      delegate :document_type, :document_id, to: :person_data
      delegate :address, :postal_code, to: :person_data
      delegate :membership_level, :gender, to: :person_data
      delegate :state, to: :person_data
      delegate :id, to: :scope, prefix: true
      delegate :id, to: :address_scope, prefix: true
      delegate :id, to: :document_scope, prefix: true

      def initialize(person_data)
        @person_data = OpenStruct.new(person_data)
      end

      def scope
        @scope ||= Decidim::Scope.find_by(code: person_data.scope_code)
      end

      def address_scope
        @address_scope ||= Decidim::Scope.find_by(code: person_data.address_scope_code)
      end

      def document_scope
        @document_scope ||= Decidim::Scope.find_by(code: person_data.document_scope_code)
      end

      def born_at
        @born_at ||= Date.parse(person_data.born_at)
      end

      def age
        @age ||= calculate_age
      end

      {
        state: STATES,
        verification: VERIFICATIONS,
        membership_level: MEMBERSHIP_LEVELS
      }.each do |attribute, values|
        values.each do |value|
          define_method "#{value}?" do
            @person_data[attribute] == value
          end
        end
      end

      private

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

      attr_reader :person_data
    end
  end
end
