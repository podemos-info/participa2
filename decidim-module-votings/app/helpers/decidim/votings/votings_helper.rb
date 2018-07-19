# frozen_string_literal: true

module Decidim
  module Votings
    # Helper methods for votings.
    module VotingsHelper
      def end_date_changed(date)
        date -= 1.second if date.hour.zero? && date.min.zero?
        date
      end

      def voting_status(voting)
        I18n.t(voting.status, scope: "activemodel.attributes.voting.statuses")
      end
    end
  end
end
