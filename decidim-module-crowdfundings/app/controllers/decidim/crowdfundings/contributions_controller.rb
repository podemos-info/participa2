# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Controller responsible of managing contributions
    class ContributionsController < Decidim::Crowdfundings::ApplicationController
      include NeedsCampaign
      include CensusAPI

      helper Decidim::Crowdfundings::ContributionsHelper

      def create
        enforce_permission_to :support, :campaign, campaign: campaign

        @form = confirm_contribution_form
                .from_params(params, campaign: campaign)
        CreateContribution.call(@form) do
          on(:ok) do
            successful_creation
          end

          on(:credit_card) do |census|
            credit_card_creation(census[:form])
          end

          on(:invalid) do
            invalid_creation
          end
        end
      end

      # Marks the given contribution as accepted or rejected,
      # depending on the response response received through the
      # result attribute
      def validate
        accept_contribution if params[:result] == "ok"
        reject_contribution if params[:result] == "ko"

        redirect_to EngineRouter.main_proxy(current_component)
                                .campaign_path(contribution.campaign)
      end

      def accept_contribution
        contribution.update(state: "accepted")
        flash[:notice] = I18n.t(
          "contributions.validate.success",
          scope: "decidim.crowdfundings"
        )
      end

      def reject_contribution
        contribution.update(state: "rejected")
        flash[:alert] = I18n.t(
          "contributions.validate.invalid",
          scope: "decidim.crowdfundings"
        )
      end

      def confirm
        @form = contribution_form
                .from_params(params, campaign: campaign)

        if @form.valid?
          @form = confirm_contribution_form
                  .from_params(params, campaign: campaign)
          @form.correct_payment_method
        else
          render "/decidim/crowdfundings/campaigns/show"
        end
      end

      private

      def invalid_creation
        flash.now[:alert] = I18n.t(
          "contributions.create.invalid",
          scope: "decidim.crowdfundings"
        )
        render action: "confirm"
      end

      def successful_creation
        flash[:notice] = I18n.t(
          "contributions.create.success",
          scope: "decidim.crowdfundings"
        )

        redirect_to EngineRouter.main_proxy(current_component)
                                .campaign_path(campaign)
      end

      def credit_card_creation(form_data)
        @census = form_data
        render "/decidim/crowdfundings/contributions/census_credit_card"
      end

      def contribution
        @contribution ||= Contribution.find(params[:id])
      end

      def contribution_form
        form(Decidim::Crowdfundings::ContributionForm)
      end

      def confirm_contribution_form
        form(Decidim::Crowdfundings::ConfirmContributionForm)
      end
    end
  end
end
