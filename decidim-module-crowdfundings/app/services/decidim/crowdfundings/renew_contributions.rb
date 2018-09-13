# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Class responsible of renewing a set of contributions
    class RenewContributions
      # Sugar syntax that executes the renew process
      # for all contribution frequencies
      def self.run
        payments_proxy = PaymentsProxy.new
        new(payments_proxy, PendingAnnualContributions.new).run
        new(payments_proxy, PendingQuarterlyContributions.new).run
        new(payments_proxy, PendingMonthlyContributions.new).run
      end

      # Initializes the service with the list of
      # contributions that need to be renewed.
      def initialize(payments_proxy, contributions)
        @contributions = contributions
        @payments_proxy = payments_proxy
      end

      # Executes the renew process
      def run
        contributions.each do |contribution|
          payments_proxy.person_proxy = Decidim::CensusConnector::PersonProxy.for(contribution.user)
          RenewContribution.new(payments_proxy, contribution).call
        end
      end

      private

      attr_reader :contributions, :payments_proxy
    end
  end
end
