# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Class responsible of refreshing status for pending contributions.
    class RefreshContributions
      # Sugar syntax that executes the the renew process
      # for all frequencies
      def self.run
        new(UnconfirmedContributions.new).run
      end

      # Initializes the service with the list of
      # contributions that need to be renewed.
      def initialize(contributions)
        @contributions = contributions
      end

      # Executes the renew process
      def run
        contributions.each do |contribution|
          RefreshContribution.new(contribution).call
        end
      end

      private

      attr_reader :contributions
    end
  end
end
