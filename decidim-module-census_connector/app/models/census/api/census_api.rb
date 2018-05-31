# frozen_string_literal: true

require "active_support/concern"
require "faraday"

module Census
  module API
    module CensusAPI
      extend ActiveSupport::Concern

      included do
        delegate :get, :patch, :post, to: :connection
      end

      def proxy
        return if Decidim::CensusConnector.census_api_proxy_address.blank?

        "#{Decidim::CensusConnector.census_api_proxy_address}:#{Decidim::CensusConnector.census_api_proxy_port}"
      end

      def connection
        Faraday.new(url: ::Decidim::CensusConnector.census_api_base_uri, proxy: proxy) do |conn|
          conn.request :multipart
          conn.request :url_encoded

          conn.adapter Faraday.default_adapter

          conn.response :logger, ::Logger.new(STDOUT), bodies: true if Decidim::CensusConnector.census_api_debug
        end
      end

      def send_request
        response = yield

        http_response_code = response.status
        return { http_response_code: http_response_code } if [500, 204].include?(http_response_code)

        json_response = JSON.parse(response.body, symbolize_names: true)
        json_response[:http_response_code] = http_response_code
        json_response
      end
    end
  end
end
