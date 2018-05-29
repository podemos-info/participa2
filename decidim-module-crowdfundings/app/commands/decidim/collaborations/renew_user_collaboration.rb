# frozen_string_literal: true

module Decidim
  module Collaborations
    # Rectify command that renews a recurrent a user collaboration
    class RenewUserCollaboration < Rectify::Command
      include Decidim::TranslationsHelper

      attr_reader :user_collaboration

      def initialize(user_collaboration)
        @user_collaboration = user_collaboration
      end

      # Creates the user collaboration if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) unless valid?
        census_result = renew_user_collaboration
        case census_result[:http_response_code]
        when 201
          broadcast(:ok)
        else
          broadcast(:invalid)
        end
      end

      private

      def valid?
        return false unless user_collaboration.collaboration.accepts_supports?

        user_totals = Census::API::Totals.user_totals(user_collaboration.user.id)
        return false if user_totals.nil?

        return false if user_totals >= Decidim::Collaborations.maximum_annual_collaboration

        true
      end

      def renew_user_collaboration
        result = register_on_census
        if result[:http_response_code] == 201
          user_collaboration.update(
            last_order_request_date: Time.zone.today.beginning_of_month
          )
        end

        result
      end

      def register_on_census
        Census::API::Order.create(census_parameters)
      end

      def census_parameters
        {
          person_id: user_collaboration.user.id,
          description: collaboration_description,
          amount: user_collaboration.amount * 100,
          campaign_code: user_collaboration.collaboration.id,
          payment_method_type: "existing_payment_method",
          payment_method_id: user_collaboration.payment_method_id
        }
      end

      def collaboration_description
        translated_attribute(user_collaboration.collaboration.title)
      end
    end
  end
end
