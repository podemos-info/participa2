# frozen_string_literal: true

require "faraday"

module Census
  module API
    module CensusAPI
      delegate :get, :patch, :post, to: :connection

      def proxy
        return if Decidim::CensusConnector.census_api_proxy_address.blank?

        "#{Decidim::CensusConnector.census_api_proxy_address}:#{Decidim::CensusConnector.census_api_proxy_port}"
      end

      def connection
        Faraday.new(url: ::Decidim::CensusConnector.census_api_base_uri, proxy: proxy) do |conn|
          conn.request :multipart
          conn.request :url_encoded

          conn.response :logger, ::Logger.new(STDOUT), bodies: true if Decidim::CensusConnector.census_api_debug

          conn.adapter Faraday.default_adapter
        end
      end

      def send_request
        begin
          response = yield

          http_response_code = response.status
          http_response_body = response.body
        rescue Errno::ECONNREFUSED
          http_response_code = 500
          http_response_body = "\n****** Census is down! ******\n"
        end

        if [500, 204].include?(http_response_code)
          Rails.logger.warn http_response_body

          return { http_response_code: http_response_code }
        end

        json_response = JSON.parse(http_response_body, symbolize_names: true)
        json_response[:http_response_code] = http_response_code
        json_response
      end
    end
  end
end
