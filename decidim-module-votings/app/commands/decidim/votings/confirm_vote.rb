# frozen_string_literal: true

module Decidim
  module Votings
    # This command is executed when the voting system confirms a Vote
    class ConfirmVote < Rectify::Command
      def initialize(voting_identifier:, voter_identifier:)
        @voting_identifier = voting_identifier
        @voter_identifier = voter_identifier
      end

      # Creates the project if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) unless confirm(Vote) || confirm(SimulatedVote)

        broadcast(:ok)
      end

      private

      attr_reader :voting_identifier, :voter_identifier

      def confirm(vote_type)
        vote_type.where(voting_identifier: voting_identifier, voter_identifier: voter_identifier)
                 .update_all(status: :confirmed) == 1 # rubocop:disable Rails/SkipsModelValidations
      end
    end
  end
end
