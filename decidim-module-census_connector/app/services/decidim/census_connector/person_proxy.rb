# frozen_string_literal: true

module Decidim
  module CensusConnector
    class PersonProxy
      def self.for(user)
        census_authorization = Decidim::Authorization.find_or_initialize_by(
          user: user,
          name: "census"
        ) do |authorization|
          authorization.metadata = {}
        end

        new(census_authorization)
      end

      def initialize(authorization)
        @authorization = authorization
      end

      attr_reader :authorization

      def user
        @user ||= authorization.user
      end

      def person_id
        @person_id ||= authorization.metadata["person_id"]
      end

      def has_person?
        person_id.present? && census_person_id.present?
      end

      def census_person_id
        census_person[:id]
      end

      def census_person_api_connection
        @census_person_api_connection ||= ::Census::API::Person.new(person_id)
      end

      def census_person
        @census_person ||= census_person_api_connection.find
      end

      def person
        @person ||= Person.new(census_person) if has_person?
      end
    end
  end
end
