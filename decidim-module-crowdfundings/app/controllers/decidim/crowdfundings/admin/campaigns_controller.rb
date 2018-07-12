# frozen_string_literal: true

module Decidim
  module Crowdfundings
    module Admin
      class CampaignsController < Admin::ApplicationController
        before_action :init_form_from_params, only: [:create, :update]

        helper Decidim::Crowdfundings::TotalsHelper

        def new
          @form = campaign_form.instance
          @form.amounts = Decidim::Crowdfundings.selectable_amounts.join(", ")
        end

        def create
          CreateCampaign.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("campaigns.create.success", scope: "decidim.crowdfundings.admin")
              redirect_to campaigns_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("campaigns.create.invalid", scope: "decidim.crowdfundings.admin")
              render action: "new"
            end
          end
        end

        def edit
          @form = campaign_form.from_model(campaign)
        end

        def update
          UpdateCampaign.call(@form, campaign) do
            on(:ok) do
              flash[:notice] = I18n.t("campaigns.update.success", scope: "decidim.crowdfundings.admin")
              redirect_to campaigns_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("campaigns.update.invalid", scope: "decidim.crowdfundings.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          campaign.destroy!
          flash[:notice] = I18n.t("campaigns.destroy.success", scope: "decidim.crowdfundings.admin")
          redirect_to campaigns_path
        end

        private

        def init_form_from_params
          @form = campaign_form.from_params(params)
        end

        def campaign_form
          form(CampaignForm)
        end
      end
    end
  end
end
