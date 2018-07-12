# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Returns recurrent quarterly contributions that must be renewed
    class PendingQuarterlyContributions < Rectify::Query
      def query
        Contribution.is_accepted.quarterly_frequency
      end
    end
  end
end
