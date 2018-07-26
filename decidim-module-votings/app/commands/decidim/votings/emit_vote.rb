# frozen_string_literal: true

module Decidim
  module Votings
    # This command is executed when the user emits a Vote
    class EmitVote < Rectify::Command
      def initialize(user:, voting:, voting_identifier:)
        @user = user
        @voting = voting
        @voting_identifier = voting_identifier
      end

      # Creates or updates the vote
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) unless user && voting && voting_identifier && vote

        broadcast(:ok, vote)
      end

      private

      attr_reader :user, :voting, :voting_identifier

      def vote
        @vote ||= vote_class.upsert(all_attributes)
      end

      def all_attributes
        {
          user: user,
          voting: voting,
          voting_identifier: voting_identifier,
          status: :pending,
          **simulation_attributes
        }
      end

      def simulation_attributes
        if voting.simulating?
          { simulation_code: voting.simulation_code }
        else
          {}
        end
      end

      def vote_class
        @vote_class ||= voting.simulating? ? SimulatedVote : Vote
      end
    end
  end
end
