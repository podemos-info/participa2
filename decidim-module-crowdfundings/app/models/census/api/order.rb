# frozen_string_literal: true

module Census
  module API
    # This class represents an Order in Census API
    class Order
      include CensusAPI

      def self.create(params)
        response = post_order("/api/v1/payments/orders", body: params)

        return { http_response_code: response.code, message: response.message } if response.code / 100 == 5

        json_response = JSON.parse(response.body, symbolize_names: true)
        json_response[:http_response_code] = response.code
        json_response
      end

      def self.post_order(url, body:)
        post("/api/v1/payments/orders", body: body)
      rescue StandardError => e
        Rails.logger.debug "Request to #{url} failed with code #{e.response.code}: #{e.response.message}"

        e.response
      end

      private_class_method :post_order
    end
  end
end
