# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Returns recurrent annual contributions that must be renewed
    class PendingAnnualContributions < Rectify::Query
      def query
        Contribution.is_accepted.annual_frequency
      end
    end
  end
end
