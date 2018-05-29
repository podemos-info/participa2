# frozen_string_literal: true

module Decidim
  module Collaborations
    # Returns recurrent user collaborations for the given user.
    class RecurrentCollaborations < Rectify::Query
      attr_reader :user

      # Sugar syntax. Allow calling the query in a more expressive way.
      def self.for_user(user)
        new(user)
      end

      # Initializes the query. Accepts the Decidim::User which recurrent
      # collaborations must be retreived.
      def initialize(user)
        @user = user
      end

      def query
        UserCollaboration
          .includes(:collaboration, :user)
          .supported_by(user)
          .where.not(frequency: "punctual")
          .order(created_at: :desc)
      end
    end
  end
end
