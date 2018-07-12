# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Returns unconfirmed contributions
    class UnconfirmedContributions < Rectify::Query
      def query
        Contribution.is_pending
      end
    end
  end
end
