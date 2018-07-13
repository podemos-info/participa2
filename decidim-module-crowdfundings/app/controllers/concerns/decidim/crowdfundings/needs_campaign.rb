# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # This module, when injected into a controller, ensures there's a
    # campaign available and deducts it from the context.
    module NeedsCampaign
      def self.included(base)
        base.include InstanceMethods

        enhance_controller(base)
      end

      def self.enhance_controller(instance_or_module)
        instance_or_module.class_eval do
          helper_method :campaign, :recurrent_contribution, :error_message

          helper Decidim::Crowdfundings::CampaignsHelper
          helper Decidim::Crowdfundings::TotalsHelper
        end
      end

      module InstanceMethods
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

        def error_message
          @error_message ||= if campaign.inactive?
                               :support_period_finished
                             elsif unavailable_service?
                               :contribution_not_allowed
                             elsif maximum_annual_exceeded?
                               :maximum_annual_exceeded
                             end
        end

        def unavailable_service?
          under_annual_limit.nil?
        end

        def maximum_annual_exceeded?
          under_annual_limit == false
        end

        def under_annual_limit
          @under_annual_limit ||= campaign.under_annual_limit?(current_user)
        end
      end
    end
  end
end
