# frozen_string_literal: true

module Decidim
  module CensusConnector
    class PersonProxy
      def self.for(user, version_at: nil)
        census_authorization = Decidim::Authorization.find_or_initialize_by(
          user: user,
          name: "census"
        ) do |authorization|
          authorization.metadata = {}
        end

        new(census_authorization, version_at: version_at)
      end

      def initialize(authorization, version_at: nil)
        @authorization = authorization
        @version_at = version_at
      end

      attr_reader :authorization

      def user
        @user ||= authorization.user
      end

      def person_id
        @person_id ||= authorization.metadata["person_id"]
      end

      def has_person?
        person_id.present?
      end

      def person
        @person ||= Person.new(census_person) if has_person?
      end

      def census_person_api
        @census_person_api ||= ::Census::API::Person.new(person_id)
      end

      private

      def census_person
        @census_person ||= census_person_api.find(**census_person_params)
      end

      def census_person_params
        @census_person_params ||= if @version_at
                                    { version_at: @version_at }
                                  else
                                    {}
                                  end
      end
    end
  end
end
