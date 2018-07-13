# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Rectify command that refresh a pending contribution
    class RefreshContribution < Rectify::Command
      attr_reader :contribution

      def initialize(contribution)
        @contribution = contribution
      end

      # Creates the contribution if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        census_result = retrieve_payment_method_data
        case census_result[:http_response_code]
        when 200
          refresh_contribution_status(census_result)
          broadcast(:ok)
        else
          broadcast(:invalid)
        end
      end

      private

      def retrieve_payment_method_data
        Census::API::PaymentMethod.payment_method(
          contribution.payment_method_id
        )
      end

      def refresh_contribution_status(census_result)
        return if census_result[:status] == "pending"

        contribution.update(state: "accepted") if census_result[:status] == "active"

        contribution.update(state: "rejected") if census_result[:status] == "inactive"
      end
    end
  end
end
