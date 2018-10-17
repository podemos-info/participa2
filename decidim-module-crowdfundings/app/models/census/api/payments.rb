# frozen_string_literal: true

module Census
  module API
    # This class represents payments requests in Census API
    class Payments
      include CensusAPI

      # PUBLIC create an order for the given person
      def create_order(qualified_id, **params)
        params[:amount] *= 100
        process_response(
          send_request { post(api_url("payments/orders"), params.merge(person_id: qualified_id)) }
        )
      end

      # PUBLIC retrieve the available payment methods for the given person.
      def payment_methods(qualified_id)
        process_response(
          send_request { get(api_url("payments/payment_methods"), person_id: qualified_id) }
        ) do |payment_methods_info|
          payment_methods_info.map do |payment_method_info|
            Decidim::Crowdfundings::PaymentMethod.new(payment_method_info)
          end
        end
      end

      # PUBLIC retrieve the details for the given payment method
      def payment_method(payment_method_id)
        return [:invalid, {}] if payment_method_id.blank?

        process_response(
          send_request { get(api_url("payments/payment_methods/#{payment_method_id}")) }
        ) do |payment_method_info|
          Decidim::Crowdfundings::PaymentMethod.new(payment_method_info)
        end
      end

      # PUBLIC retrieve the total amount for the orders that matches the given filters
      def orders_total(**params)
        process_response(
          send_request { get(api_url("payments/orders/total"), params.slice(:person_id, :campaign_code, :from_date, :until_date)) }
        ) do |response|
          response[:amount] / 100
        end
      end
    end
  end
end
