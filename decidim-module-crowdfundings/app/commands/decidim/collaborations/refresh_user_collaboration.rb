# frozen_string_literal: true

module Decidim
  module Collaborations
    # Rectify command that refresh a pending user collaboration
    class RefreshUserCollaboration < Rectify::Command
      attr_reader :user_collaboration

      def initialize(user_collaboration)
        @user_collaboration = user_collaboration
      end

      # Creates the user collaboration if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        census_result = retrieve_payment_method_data
        case census_result[:http_response_code]
        when 200
          refresh_collaboration_status(census_result)
          broadcast(:ok)
        else
          broadcast(:invalid)
        end
      end

      private

      def retrieve_payment_method_data
        Census::API::PaymentMethod.payment_method(
          user_collaboration.payment_method_id
        )
      end

      def refresh_collaboration_status(census_result)
        return if census_result[:status] == "pending"

        user_collaboration.update(state: "accepted") if census_result[:status] == "active"

        user_collaboration.update(state: "rejected") if census_result[:status] == "inactive"
      end
    end
  end
end
