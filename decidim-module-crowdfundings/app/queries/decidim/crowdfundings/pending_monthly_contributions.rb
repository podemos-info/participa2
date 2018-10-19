# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Returns recurrent monthly contributions that must be renewed
    class PendingMonthlyContributions < Rectify::Query
      def query
        Contribution.accepted.monthly_frequency
      end
    end
  end
end
