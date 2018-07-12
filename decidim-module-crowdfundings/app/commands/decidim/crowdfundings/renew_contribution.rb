# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Rectify command that renews a recurrent contribution
    class RenewContribution < Rectify::Command
      include Decidim::TranslationsHelper

      attr_reader :contribution

      def initialize(contribution)
        @contribution = contribution
      end

      # Creates the contribution if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) unless valid?
        census_result = renew_contribution
        case census_result[:http_response_code]
        when 201
          broadcast(:ok)
        else
          broadcast(:invalid)
        end
      end

      private

      def valid?
        return false unless contribution.campaign.accepts_supports?
        return false unless contribution.campaign.under_annual_limit?(contribution.user)

        true
      end

      def renew_contribution
        result = register_on_census
        if result[:http_response_code] == 201
          contribution.update(
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
          person_id: contribution.user.id,
          description: contribution_description,
          amount: contribution.amount * 100,
          campaign_code: contribution.campaign.id,
          payment_method_type: "existing_payment_method",
          payment_method_id: contribution.payment_method_id
        }
      end

      def contribution_description
        translated_attribute(contribution.campaign.title)
      end
    end
  end
end
