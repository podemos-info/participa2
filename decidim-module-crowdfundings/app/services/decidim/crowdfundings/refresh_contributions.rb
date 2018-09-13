# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Class responsible of refreshing status for pending contributions.
    class RefreshContributions
      # Sugar syntax that executes the the renew process
      # for all frequencies
      def self.run
        payments_proxy = PaymentsProxy.new
        new(payments_proxy, UnconfirmedContributions.new).run
      end

      # Initializes the service with the list of
      # contributions that need to be renewed.
      def initialize(payments_proxy, contributions)
        @payments_proxy = payments_proxy
        @contributions = contributions
      end

      # Executes the renew process
      def run
        contributions.each do |contribution|
          payments_proxy.person_proxy = Decidim::CensusConnector::PersonProxy.for(contribution.user)
          RefreshContribution.new(payments_proxy, contribution).call
        end
      end

      private

      attr_reader :contributions, :payments_proxy
    end
  end
end
