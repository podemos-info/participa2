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
      delegate :service_status, to: :census_person_api

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
        @person ||= Person.new(authorization.metadata) { census_person } if has_person?
      end

      # PUBLIC creates a person with the given params.
      def create(**params)
        census_person_api.create(**params).tap do |result, person_id|
          authorization.update!(metadata: { "person_id" => person_id }) if result == :ok
        end
      end

      # PUBLIC update the person with the given params.
      def update(**params)
        census_person_api.update(qualified_id, **params)
      end

      # PUBLIC add a verification process for the person.
      def create_verification(**params)
        census_person_api.create_verification(qualified_id, **params)
      end

      # PUBLIC associate a membership level for the person.
      def create_membership_level(**params)
        census_person_api.create_membership_level(qualified_id, **params)
      end

      def service_status(force_check: false)
        person.load_deferred_person_data if force_check && census_person_api.service_status.nil?
        census_person_api.service_status
      end

      private

      def qualified_id
        raise "Person ID not available" unless person_id

        "#{person_id}@census"
      end

      def census_person_api
        @census_person_api ||= ::Census::API::Person.new
      end

      def census_person
        @census_person ||= census_person_api.if_valid(census_person_api.find(qualified_id, **census_person_params))
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
