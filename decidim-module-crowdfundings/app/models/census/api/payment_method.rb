# frozen_string_literal: true

module Census
  module API
    # This class represents a payment method in Census
    class PaymentMethod
      include CensusAPI

      PAYMENT_METHOD_TYPES = [:existing_payment_method, :direct_debit, :credit_card_external].freeze

      # PUBLIC retrieve the available payment methods for the given user.
      def self.for_user(person_id)
        response = get(
          "/api/v1/payments/payment_methods",
          query: { person_id: person_id }
        )

        return [] if response.code != 200
        JSON.parse(response.body, symbolize_names: true)
      rescue StandardError => e
        Rails.logger.debug "Request to /api/v1/payments/payment_methods failed with code #{e.response.code}: #{e.response.message}"
        []
      end

      # PUBLIC retrieve the details for the given payment method
      def self.payment_method(id)
        response = get(
          "/api/v1/payments/payment_method",
          query: { id: id }
        )
        json_response = JSON.parse(response.body, symbolize_names: true)
        json_response[:http_response_code] = response.code.to_i

        json_response
      rescue StandardError => e
        { http_response_code: e.response.code.to_i }
      end
    end
  end
end
