# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Crowdfundings
    # This cell renders a crowdfunding campaign with its M-size card.
    class CampaignMCell < Decidim::CardMCell
      include CampaignCellsHelper

      private

      alias campaign model

      def title
        translated_attribute campaign.title
      end

      def description
        translated_attribute campaign.description
      end

      def has_amount?
        campaign.target_amount.present?
      end

      def current_component
        campaign.component
      end

      def payments_proxy
        context[:payments_proxy]
      end
    end
  end
end
