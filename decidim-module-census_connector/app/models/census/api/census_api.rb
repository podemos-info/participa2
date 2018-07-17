# frozen_string_literal: true

require "faraday"

module Census
  module API
    module CensusAPI
      extend ActiveSupport::Concern

      included do
        attr_reader :person_id, :errors, :global_error
      end

      def initialize(person_id = nil)
        @person_id = person_id
      end

      def qualified_id
        raise "Person ID not available" unless person_id

        "#{person_id}@census"
      end

      delegate :get, :patch, :post, to: :connection

      def ensure_person(params = {})
        raise "Person ID not available" unless person_id || params[:person_id]

        params[:person_id] = person_id
        params
      end

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

        if [200, 202, 422].include?(http_response_code)
          json_response = JSON.parse(http_response_body, symbolize_names: true)
          json_response[:http_response_code] = http_response_code
          json_response
        else
          Rails.logger.warn http_response_body

          { http_response_code: http_response_code }
        end
      end

      def valid?(response)
        http_response_code = response.delete(:http_response_code)

        if [202, 204].include?(http_response_code)
          true
        elsif http_response_code == 422
          @errors = response

          false
        else
          @global_error = I18n.t("census.api.global_error")

          false
        end
      end
    end
  end
end
