# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Crowdfundings
    # This concern add methods and helpers to simplify access to census payments context.
    module CensusPaymentsContext
      extend ActiveSupport::Concern

      included do
        helper_method :payments_proxy

        include Decidim::CensusConnector::CensusContext
      end

      def payments_proxy
        @payments_proxy ||= Decidim::Crowdfundings::PaymentsProxy.new(person_proxy, user_request: request)
      end
    end
  end
end
