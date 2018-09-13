# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Crowdfundings
    # This module, when injected into a controller, ensures there's a
    # campaign available and deducts it from the context.
    module NeedsCampaign
      extend ActiveSupport::Concern

      included do
        helper_method :campaign, :recurrent_contribution, :payment_methods, :contribution_error

        helper Decidim::Crowdfundings::CampaignsHelper
        helper Decidim::Crowdfundings::TotalsHelper
      end

      # Public: Finds the current campaign given this controller's
      # context.
      #
      # Returns the current crowdfundings campaign.
      def campaign
        @campaign ||= detect_campaign
      end

      # Public: Finds the current recurrent contribution (if any) given
      # this controller's context.
      #
      # Returns the current user recurrent contribution.
      def recurrent_contribution
        @recurrent_contribution ||= detect_recurrent_contribution
      end

      private

      delegate :payment_methods, to: :payments_proxy

      def contribution_error
        @contribution_error ||= begin
          if campaign.accepts_contributions?
            payments_proxy.contribution_error
          else
            :support_period_finished
          end
        end
      end

      def detect_campaign
        Campaign.find_by(id: params[:campaign_id] || params[:id])
      end

      def detect_recurrent_contribution
        return unless campaign

        recurrent_contributions = CampaignRecurrentContributions.new(current_user, campaign)

        return if recurrent_contributions.none?
        raise "Multiple recurrent contributions for the same campaign!" unless recurrent_contributions.one?

        recurrent_contributions.first
      end
    end
  end
end
