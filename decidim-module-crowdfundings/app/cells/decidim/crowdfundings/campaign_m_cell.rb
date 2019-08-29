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
        if recurrent_contribution
          t(
            "current_#{recurrent_contribution.state}_recurrent_support",
            amount: decidim_number_to_currency(recurrent_contribution.amount),
            periodicity: frequency_label(recurrent_contribution.frequency).downcase,
            scope: "decidim.crowdfundings.campaigns.show"
          )
        else
          translated_attribute campaign.description
        end
      end

      def has_amount?
        campaign.target_amount.present?
      end

      def current_component
        campaign.component
      end

      def payments_proxy
        context[:payments_proxy] || controller.payments_proxy
      end

      def recurrent_contribution
        return nil unless campaign.recurrent_support_allowed?
        return @recurrent_contribution if defined?(@recurrent_contribution)

        @recurrent_contribution = CampaignRecurrentContributions.new(current_user, campaign).first
      end

      def has_recurrent_contribution?
        recurrent_contribution.present?
      end

      def recurrent_contribution_path
        Decidim::Crowdfundings::UserProfileEngine.routes.url_helpers.edit_contribution_path(recurrent_contribution)
      end
    end
  end
end
