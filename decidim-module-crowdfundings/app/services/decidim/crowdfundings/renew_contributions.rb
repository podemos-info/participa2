# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Class responsible of renewing a set of contributions
    class RenewContributions
      # Sugar syntax that executes the renew process
      # for all contribution frequencies
      def self.run
        new(PendingAnnualContributions.new).run
        new(PendingQuarterlyContributions.new).run
        new(PendingMonthlyContributions.new).run
      end

      # Initializes the service with the list of
      # contributions that need to be renewed.
      def initialize(contributions)
        @contributions = contributions
      end

      # Executes the renew process
      def run
        contributions.each do |contribution|
          RenewContribution.new(contribution).call
        end
      end

      private

      attr_reader :contributions
    end
  end
end
