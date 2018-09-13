# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Returns recurrent contributions for the given user.
    class RecurrentContributions < Rectify::Query
      attr_reader :user

      # Sugar syntax. Allow calling the query in a more expressive way.
      def self.for_user(user)
        new(user)
      end

      # Initializes the query. Accepts the Decidim::User which recurrent
      # contributions must be retreived.
      def initialize(user)
        @user = user
      end

      def query
        Contribution
          .includes(:campaign, :user)
          .supported_by(user)
          .recurrent
          .order(created_at: :desc)
      end
    end
  end
end
