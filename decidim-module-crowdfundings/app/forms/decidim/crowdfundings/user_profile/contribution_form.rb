# frozen_string_literal: true

module Decidim
  module Crowdfundings
    module UserProfile
      # This class holds a Form to create contributions
      class ContributionForm < Decidim::Form
        mimic :contribution

        attribute :amount, Integer
        attribute :frequency, String

        validates :amount,
                  presence: true,
                  numericality: { only_integer: true, greater_than: 0 }

        validates :frequency, presence: true, inclusion: { in: Contribution.frequencies }

        validate :contributions_allowed
        validate :minimum_custom_amount
        validate :maximum_amount

        delegate :campaign, :contribution, to: :context

        def description
          campaign.title[Decidim.default_locale.to_s]
        end

        def campaign_code
          campaign.reference
        end

        private

        delegate :payments_proxy, to: :context

        def contributions_allowed
          return if campaign.accepts_contributions?

          errors.add(
            :campaign,
            I18n.t("support_status.support_period_finished", scope: "decidim.crowdfundings")
          )
        end

        # This validator method checks that the amount set by the user is
        # higher or equal to the minimum value allowed for custom amounts
        def minimum_custom_amount
          return if !amount || campaign.amounts.include?(amount) || amount >= campaign.minimum_custom_amount

          errors.add(
            :amount,
            I18n.t(
              "amount.minimum_valid_amount",
              amount: campaign.minimum_custom_amount,
              scope: "activemodel.errors.models.contribution.attributes"
            )
          )
        end

        # This validator method checks that the amount set by the user do not
        # increases the annual accumulated amount over the maximum allowed
        def maximum_amount
          return if !amount || payments_proxy.under_annual_limit?(add_amount: amount)

          errors.add(
            :amount,
            I18n.t(
              "amount.annual_limit_exceeded",
              scope: "activemodel.errors.models.contribution.attributes"
            )
          )
        end
      end
    end
  end
end
