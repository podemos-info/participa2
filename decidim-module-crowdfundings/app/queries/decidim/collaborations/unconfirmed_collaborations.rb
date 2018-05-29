# frozen_string_literal: true

module Decidim
  module Collaborations
    # Returns recurrent quarterly user collaborations that must be renewed
    class UnconfirmedCollaborations < Rectify::Query
      def query
        UserCollaboration.is_pending
      end
    end
  end
end
