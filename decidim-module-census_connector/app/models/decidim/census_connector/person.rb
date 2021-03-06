# frozen_string_literal: true

module Decidim
  module CensusConnector
    class Person
      include Census::API::PersonDefinitions

      attr_reader :user

      delegate :id, to: :scope, prefix: true
      delegate :id, to: :address_scope, prefix: true
      delegate :id, to: :document_scope, prefix: true

      def initialize(user, person_data, &block)
        @user = user
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

      PHONE_VERIFICATIONS.each do |value|
        define_method "#{value}_phone?" do
          phone_verification == value
        end
      end

      def born_at
        @born_at ||= Date.parse(_born_at) if _born_at.present?
      end

      def scope
        @scope ||= @user.organization.scopes.find_by(code: scope_code)
      end

      def address_scope
        @address_scope ||= @user.organization.scopes.find_by(code: address_scope_code)
      end

      def document_scope
        @document_scope ||= @user.organization.scopes.find_by(code: document_scope_code)
      end

      def min_age
        return @min_age if defined?(@min_age)

        @min_age = person_data["age"] || 0
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

        defer_data = defer_person_data.call unless defer_person_data.nil?
        @defer_person_data = nil
        @deferred_person_data = defer_data&.stringify_keys
      end

      def calculate_age
        (Time.zone.today.to_s(:number).to_i - born_at.to_s(:number).to_i) / 10_000
      end
    end
  end
end
