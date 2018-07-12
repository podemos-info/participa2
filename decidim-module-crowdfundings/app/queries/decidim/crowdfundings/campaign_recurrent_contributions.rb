# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Returns recurrent contributions for a given campaign and a user.
    class CampaignRecurrentContributions < Rectify::Query
      attr_reader :user, :campaign

      # Initializes the query. Accepts the Decidim::User and a
      # Decidim::Crowdfundings::Campaign for which
      # contributions must be retrieved.
      def initialize(user, campaign)
        @user = user
        @campaign = campaign
      end

      def query
        RecurrentContributions.new(user).query.where(campaign: campaign)
      end
    end
  end
end
