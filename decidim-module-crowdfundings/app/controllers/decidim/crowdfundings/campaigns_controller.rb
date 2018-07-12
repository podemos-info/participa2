# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Exposes crowdfundings campaigns to users.
    class CampaignsController < Decidim::Crowdfundings::ApplicationController
      include FilterResource
      include CensusAPI

      helper_method :campaigns, :random_seed
      helper Decidim::PaginateHelper
      helper Decidim::ParticipatoryProcesses::ParticipatoryProcessHelper

      include NeedsCampaign

      def index
        return unless component_campaigns.count == 1

        redirect_to EngineRouter.main_proxy(current_component)
                                .campaign_path(component_campaigns.first)
      end

      def show
        @form = contribution_form.instance(campaign: campaign)
        initialize_form_defaults
      end

      private

      def initialize_form_defaults
        @form.amount = campaign.default_amount
        @form.frequency = if campaign.recurrent_support_allowed?
                            Decidim::Crowdfundings.default_frequency
                          else
                            "punctual"
                          end
      end

      def campaigns
        @campaigns ||= search.results
                             .page(params[:page])
                             .per(Decidim::Crowdfundings.campaigns_shown_per_page)
      end

      def component_campaigns
        Campaign.for_component(current_component)
      end

      def random_seed
        @random_seed ||= search.random_seed
      end

      def search_klass
        CampaignSearch
      end

      def default_filter_params
        {
          search_text: "",
          random_seed: params[:random_seed]
        }
      end

      def context_params
        { component: current_component, organization: current_organization }
      end

      def contribution_form
        form(Decidim::Crowdfundings::ContributionForm)
      end
    end
  end
end
