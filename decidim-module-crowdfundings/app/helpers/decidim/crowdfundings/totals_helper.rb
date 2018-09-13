# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Helper methods for totals partial
    module TotalsHelper
      # PUBLIC: Generates the ID for the totals block.
      def totals_block_id(user)
        if user
          "overall-totals-user-#{user.id}"
        else
          "overall-totals-block"
        end
      end

      # PUBLIC: Generate title for totals block. The result may vary depending
      # on the totals scope: global or user.
      def totals_title(user)
        if user
          I18n.t("user_totals", scope: "decidim.crowdfundings.campaigns.totals")
        else
          I18n.t("overall_totals", scope: "decidim.crowdfundings.campaigns.totals")
        end
      end

      # PUBLIC: Retrieves total collected depending on the context for totals
      # block
      def total_collected(campaign, user = nil)
        if user
          total_collected_to_currency(person_campaign_total(campaign)) if payments_proxy.has_person?
        else
          total_collected_to_currency campaign_total(campaign)
        end
      end

      # PUBLIC: Returns percentage value formatted as a percentage without
      # decimal places.
      def percentage(campaign, user = nil)
        value = total_percentage(campaign, user)
        return I18n.t("decidim.crowdfundings.labels.not_available") if value.nil?

        number_to_percentage value, precision: 0
      end

      # PUBLIC: Generates a tag that represents the current percentage with
      # regards to the target objective of the campaign.
      # When user is nil it represents the overall percentage. Otherwise it
      # represents the user percentage.
      def percentage_tag(campaign, user = nil)
        css_class = percentage_class(total_percentage(campaign, user))

        content_tag(:div,
                    class: "extra__percentage percentage #{css_class}".strip) do

          output = []
          5.times do
            output << content_tag(:span, "", class: "percentage__item")
          end

          output << content_tag(:span, "", class: "percentage__desc") do
            decidim_number_to_currency(campaign.target_amount)
            I18n.t(
              "decidim.crowdfundings.campaigns.totals.target_amount",
              amount: decidim_number_to_currency(campaign.target_amount)
            )
          end

          safe_join(output)
        end
      end

      # PUBLIC returns the percentage CSS class to apply for a given
      # percentage value.
      def percentage_class(percentage)
        return "" if percentage.blank? || percentage.negative?

        if percentage < 20
          "percentage--level1"
        elsif percentage < 50
          "percentage--level2"
        elsif percentage < 80
          "percentage--level3"
        elsif percentage < 100
          "percentage--level4"
        else
          "percentage--level5"
        end
      end

      # PUBLIC converts the amount collected into a currency string.
      def total_collected_to_currency(total_collected)
        return I18n.t("decidim.crowdfundings.labels.not_available") if total_collected.nil?
        decidim_number_to_currency(total_collected)
      end

      private

      delegate :campaign_total, :person_campaign_total, to: :payments_proxy

      def total_percentage(campaign, user)
        total = if user
                  person_campaign_total(campaign)
                else
                  campaign_total(campaign)
                end
        return 0 unless total

        (total * 100.0) / campaign.target_amount
      end
    end
  end
end
