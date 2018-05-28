# frozen_string_literal: true

module Decidim
  module Collaborations
    # Returns recurrent monthly user collaborations that must be renewed
    class PendingMonthlyCollaborations < Rectify::Query
      def query
        UserCollaboration.is_accepted.monthly_frequency
      end
    end
  end
end
