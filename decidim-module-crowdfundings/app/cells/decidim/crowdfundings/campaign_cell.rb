# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Crowdfundings
    # This cell renders the proposal card for an instance of a crowdfunding campaign
    # the default size is the Medium Card (:m)
    class CampaignCell < Decidim::ViewModel
      include Cell::ViewModel::Partial

      def show
        cell card_size, model
      end

      private

      def card_size
        "decidim/crowdfundings/campaign_m"
      end

      def resource_path
        resource_locator(model).path
      end
    end
  end
end
