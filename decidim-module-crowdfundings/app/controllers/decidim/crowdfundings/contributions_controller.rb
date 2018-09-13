# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Controller responsible of managing contributions
    class ContributionsController < Decidim::Crowdfundings::ApplicationController
      include NeedsCampaign

      helper_method :contribution_form, :confirm_form
      helper Decidim::Crowdfundings::ContributionsHelper

      def create
        enforce_permission_to :support, :campaign, campaign: campaign, payments_proxy: payments_proxy

        CreateContribution.call(payments_proxy, confirm_form) do
          on(:ok) do
            successful_creation
          end

          on(:credit_card) do |credit_card_external_form|
            credit_card_creation(credit_card_external_form)
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
        if contribution_form.invalid?
          flash[:error] = campaign_errors.first if campaign_errors.any?
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
        render "/decidim/crowdfundings/contributions/census_credit_card", layout: false
      end

      def contribution
        @contribution ||= Contribution.find(params[:id])
      end

      def contribution_form
        @contribution_form ||= form(Decidim::Crowdfundings::ContributionForm)
                               .from_params(params, campaign: campaign, payments_proxy: payments_proxy)
      end

      def confirm_form
        @confirm_form ||= form(Decidim::Crowdfundings::ConfirmContributionForm)
                          .from_params(params, campaign: campaign, payments_proxy: payments_proxy)
                          .tap do |form|
                            form.fix_payment_method
                            form.external_credit_card_return_url = validate_contribution_url(campaign, result: "__RESULT__") if form.credit_card_external?
                          end
      end

      def campaign_errors
        @campaign_errors ||= contribution_form.errors[:campaign]
      end
    end
  end
end
