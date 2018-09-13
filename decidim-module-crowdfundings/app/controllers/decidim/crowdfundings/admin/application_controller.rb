# frozen_string_literal: true

module Decidim
  module Crowdfundings
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Components::BaseController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::Admin::Components::BaseController
        helper_method :campaigns, :campaign, :payments_proxy
        helper Decidim::Crowdfundings::CampaignsHelper

        def campaigns
          @campaigns ||= Campaign.for_component(current_component)
                                 .page(params[:page])
                                 .per(Decidim::Crowdfundings.campaigns_shown_per_page)
        end

        def campaign
          @campaign ||= campaigns.find(params[:id])
        end

        def payments_proxy
          @payments_proxy ||= Decidim::Crowdfundings::PaymentsProxy.new
        end
      end
    end
  end
end
