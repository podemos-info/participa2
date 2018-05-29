# frozen_string_literal: true

module Census
  module API
    # This class represents an totals retrieval request in Census API
    class Totals
      include CensusAPI

      URL_PATH = "/api/v1/payments/orders/total"

      # PUBLIC User totals within the current year.
      # Returns the amount. Nil in case something failed.
      def self.user_totals(user_id)
        response = totals_request(
          person_id: user_id,
          from_date: Time.zone.now.beginning_of_year,
          until_date: Time.zone.now.end_of_year
        )

        process_response(response)
      rescue StandardError => e
        Rails.logger.info "[API connection error] #{e.message}"
        nil
      end

      # PUBLIC Return campaign totals.
      # Returns the amount. Nil in case something failed.
      def self.campaign_totals(campaign_id)
        response = totals_request(campaign_code: campaign_id)
        process_response(response)
      rescue StandardError => e
        Rails.logger.info "[API connection error] #{e.message}"
        nil
      end

      # PUBLIC Return User totals in the context of the given campaign.
      # Returns the amount supported by the user for the given campaign. Nil in
      # case an error occurs.
      def self.user_campaign_totals(user_id, campaign_id)
        response = totals_request(person_id: user_id, campaign_code: campaign_id)
        process_response(response)
      rescue StandardError => e
        Rails.logger.info "[API connection error] #{e.message}"
        nil
      end

      # Process response from totals service in Census.
      def self.process_response(response)
        unless response.ok?
          Rails.logger.info "[API error] #{response.body}"
          return
        end

        json = JSON.parse(response.body, symbolize_names: true)
        json[:amount]
      end

      # Performs a totals request to Census service.
      def self.totals_request(params)
        get(
          URL_PATH,
          query: params
        )
      end
    end
  end
end
