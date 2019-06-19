# frozen_string_literal: true

require "faraday"

module Census
  module API
    module CensusAPI
      extend ActiveSupport::Concern

      class << self
        attr_accessor :service_status
      end

      included do
        delegate :get, :patch, :post, :delete, to: :connection
      end

      def api_url(path)
        "/api/v1/#{I18n.locale}/#{path}"
      end

      def send_request
        response = yield
        update_service_status true
        [response.status, response.body]
      rescue Faraday::Error::ConnectionFailed => e
        update_service_status false
        [500, e.message]
      end

      def process_response(request_result)
        status, body = request_result
        if [200, 201, 202, 204].include?(status)
          info = status == 204 ? {} : JSON.parse(body, symbolize_names: true)
          info = yield(info) if block_given?
          [:ok, info]
        elsif status == 422
          [:invalid, errors: JSON.parse(body, symbolize_names: true)]
        else
          Rails.logger.warn body
          [:error, {}]
        end
      end

      def if_valid(result)
        result[1] if result[0] == :ok
      end

      def service_status
        Census::API::CensusAPI.service_status
      end

      private

      def update_service_status(status)
        Census::API::CensusAPI.service_status = status
      end

      def connection
        Faraday.new(url: ::Decidim::CensusConnector.census_api_base_uri, proxy: proxy) do |conn|
          conn.request :multipart
          conn.request :url_encoded

          conn.response :logger, ::Logger.new(STDOUT), bodies: true if Decidim::CensusConnector.census_api_debug

          conn.adapter Faraday.default_adapter
        end
      end

      def proxy
        return if Decidim::CensusConnector.census_api_proxy_address.blank?

        "#{Decidim::CensusConnector.census_api_proxy_address}:#{Decidim::CensusConnector.census_api_proxy_port}"
      end
    end
  end
end
