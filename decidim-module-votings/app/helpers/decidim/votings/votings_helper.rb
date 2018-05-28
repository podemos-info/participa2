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

      def voting_identifier_for(voting)
        return voting.voting_identifier if current_scope.blank?

        voting.voting_identifier_for(current_scope)
      end

      private

      def current_scope
        Decidim::Votings.scope_resolver.call(current_user)
      end
    end
  end
end
