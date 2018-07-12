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

        validates :frequency, presence: true
        validate :minimum_custom_amount
        validate :maximum_user_amount

        private

        # This validator method checks that the amount set by the user is
        # higher or equal to the minimum value allowed for custom amounts
        def minimum_custom_amount
          return if amount.nil?
          return if context.campaign.amounts.include? amount
          return if amount >= context.campaign.minimum_custom_amount

          errors.add(
            :amount,
            I18n.t(
              "amount.minimum_valid_amount",
              amount: context.campaign.minimum_custom_amount,
              scope: "activemodel.errors.models.contribution.attributes"
            )
          )
        end

        # This validator method checks that the amount set by the user do not
        # increases the annual accumulated amount over the maximum allowed
        def maximum_user_amount
          return if amount.nil?
          return if annual_accumulated + amount <= Decidim::Crowdfundings.maximum_annual_contribution_amount

          errors.add(
            :amount,
            I18n.t(
              "amount.annual_limit_exceeded",
              amount: context.campaign.minimum_custom_amount,
              scope: "activemodel.errors.models.contribution.attributes"
            )
          )
        end

        def annual_accumulated
          Census::API::Totals.user_totals(context.current_user.id) || Decidim::Crowdfundings.maximum_annual_contribution_amount
        end
      end
    end
  end
end
