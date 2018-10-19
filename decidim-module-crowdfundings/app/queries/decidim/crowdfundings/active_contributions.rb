# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Returns active contributions
    class ActiveContributions < Rectify::Query
      def query
        Contribution.active
      end
    end
  end
end
