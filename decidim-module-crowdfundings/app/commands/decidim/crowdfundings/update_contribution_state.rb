# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Rectify command that updates the contribution state
    class UpdateContributionState < Rectify::Command
      attr_reader :contribution, :state

      def initialize(contribution, state)
        @contribution = contribution
        @state = state
      end

      # Updates the contribution state.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        contribution.update!(state: state)
        broadcast(:ok)
      rescue StandardError => _e
        broadcast(:ko, contribution)
      end
    end
  end
end
