# frozen_string_literal: true

module Decidim
  module Collaborations
    # Returns recurrent collaborations to a given campaign for the given user.
    class UserRecurrentCampaignCollaborations < Rectify::Query
      attr_reader :user, :collaboration

      # Initializes the query. Accepts the Decidim::User and a
      # Decidim::Collaborations::Colaboration for which
      # user collaborations must be retreived.
      def initialize(user, collaboration)
        @user = user
        @collaboration = collaboration
      end

      def query
        RecurrentCollaborations.new(user).query.where(collaboration: collaboration)
      end
    end
  end
end
