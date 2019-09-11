# frozen_string_literal: true

module Decidim
  module CensusConnector
    class FullStatusChangedConsumer < ApplicationConsumer
      include ::Hutch::Consumer

      consume "census.people.full_status_changed"

      def process(message)
        params = parse_message(message)

        params[:users].each do |user|
          authorization = Decidim::Authorization.find_by(user: user, name: "census")
          next unless authorization

          authorization.metadata.merge!(params[:full_status])
          authorization.save!
        end
      end

      private

      def parse_message(message)
        body = message.body
        organization_ids = parse_external_ids(body["external_ids"])

        users = organization_ids.map do |organization_id, user_id|
          Decidim::User.find_by(decidim_organization_id: organization_id, id: user_id)
        end.compact

        {
          users: users,
          full_status: body.except("person", "external_ids")
        }
      end
    end
  end
end
