# frozen_string_literal: true

module Decidim
  module CensusConnector
    class ConfirmEmailChangeConsumer < ApplicationConsumer
      include ::Hutch::Consumer

      consume "census.people.confirm_email_change"

      def process(message)
        params = parse_message(message)

        params[:users].each do |user|
          user.email = params[:email]
          user.save!
        end
      end

      private

      def parse_message(message)
        body = message.body
        organization_ids = parse_external_ids(body["external_ids"])

        users = organization_ids.map do |organization_id, user_id|
          Decidim::User.find_by(decidim_organization_id: organization_id, id: user_id)
        end

        {
          users: users,
          email: body["email"]
        }
      end
    end
  end
end
