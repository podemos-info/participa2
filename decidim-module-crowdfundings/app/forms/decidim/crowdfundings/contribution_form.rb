# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # This class holds a Form to create a contribution
    class ContributionForm < Decidim::Form
      mimic :contribution

      attribute :amount, Integer
      attribute :frequency, String
      attribute :payment_method_type, String
      attribute :accept_terms_and_conditions, Boolean

      validates :amount,
                presence: true,
                numericality: { only_integer: true, greater_than: 0 }

      validates :frequency, presence: true, inclusion: { in: Contribution.frequencies }
      validates :payment_method_type, presence: true
      validates :accept_terms_and_conditions, presence: true
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
        return if !amount || context.campaign.under_annual_limit?(context.current_user, add_amount: amount)

        errors.add(
          :amount,
          I18n.t(
            "amount.annual_limit_exceeded",
            amount: context.campaign.minimum_custom_amount,
            scope: "activemodel.errors.models.contribution.attributes"
          )
        )
      end
    end
  end
end
