# frozen_string_literal: true

module Decidim
  module Collaborations
    # Rectify command that updates the user collaboration state
    class UpdateUserCollaborationState < Rectify::Command
      attr_reader :user_collaboration, :state

      def initialize(user_collaboration, state)
        @user_collaboration = user_collaboration
        @state = state
      end

      # Updates the user collaboration state.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        user_collaboration.update!(state: state)
        broadcast(:ok)
      rescue StandardError => _e
        broadcast(:ko, user_collaboration)
      end
    end
  end
end
