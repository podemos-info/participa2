# frozen_string_literal: true

require "active_support/concern"
require "httparty"

module Census
  module API
    module CensusAPI
      extend ActiveSupport::Concern

      included do
        include ::HTTParty

        base_uri ::Decidim::CensusConnector.census_api_base_uri

        http_proxy Decidim::CensusConnector.census_api_proxy_address, Decidim::CensusConnector.census_api_proxy_port if Decidim::CensusConnector.census_api_proxy_address.present?

        debug_output if Decidim::CensusConnector.census_api_debug

        delegate :send_request, :get, :patch, :post, to: :class
      end

      class_methods do
        def send_request
          response = yield

          http_response_code = response.code.to_i
          return { http_response_code: http_response_code } if [500, 204].include?(http_response_code)

          json_response = JSON.parse(response.body, symbolize_names: true)
          json_response[:http_response_code] = http_response_code
          json_response
        end
      end
    end
  end
end
