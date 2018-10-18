# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Returns unconfirmed contributions
    class UnconfirmedContributions < Rectify::Query
      def query
        Contribution.pending
      end
    end
  end
end
