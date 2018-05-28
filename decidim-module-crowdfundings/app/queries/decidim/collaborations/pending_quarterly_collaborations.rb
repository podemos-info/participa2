# frozen_string_literal: true

module Decidim
  module Collaborations
    # Returns recurrent quarterly user collaborations that must be renewed
    class PendingQuarterlyCollaborations < Rectify::Query
      def query
        UserCollaboration.is_accepted.quarterly_frequency
      end
    end
  end
end
