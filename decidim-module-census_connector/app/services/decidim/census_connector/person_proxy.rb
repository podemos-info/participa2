# frozen_string_literal: true

module Decidim
  module CensusConnector
    class PersonProxy
      def initialize(user: nil, authorization: nil)
        raise "PersonProxy must receive a user or an authorization" unless user || authorization

        @user = user
        @census_authorization = authorization
      end

      def census_authorization
        @census_authorization ||= Decidim::Authorization.find_or_initialize_by(
          user: user,
          name: "census"
        ) do |authorization|
          authorization.metadata = {}
        end
      end

      def user
        @user ||= census_authorization.user
      end

      def person_id
        @person_id ||= census_authorization.metadata["person_id"]
      end

      def has_person?
        person_id.present?
      end

      def person
        @person ||= Person.new(::Census::API::Person.find(census_qualified_id)) if has_person?
      end

      def census_qualified_id
        "#{person_id}@census" if person_id.present?
      end

      def local_qualified_id
        "#{user.id}@#{Decidim::CensusConnector.system_identifier}"
      end
    end
  end
end
