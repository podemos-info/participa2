# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Crowdfundings
    # This cell renders a crowdfunding campaign with its M-size card.
    class CampaignMCell < Decidim::CardMCell
      include CampaignCellsHelper

      private

      def title
        translated_attribute model.title
      end

      def description
        translated_attribute model.description
      end

      def has_amount?
        model.target_amount.present?

      def payments_proxy
        context[:payments_proxy]
      end
    end
  end
end
