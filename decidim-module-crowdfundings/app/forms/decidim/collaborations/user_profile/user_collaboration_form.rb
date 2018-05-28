# frozen_string_literal: true

module Decidim
  module Collaborations
    module UserProfile
      # This class holds a Form to create user collaborations
      class UserCollaborationForm < Decidim::Form
        mimic :user_collaboration

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
          return if context.collaboration.amounts.include? amount
          return if amount >= context.collaboration.minimum_custom_amount

          errors.add(
            :amount,
            I18n.t(
              "amount.minimum_valid_amount",
              amount: context.collaboration.minimum_custom_amount,
              scope: "activemodel.errors.models.user_collaboration.attributes"
            )
          )
        end

        # This validator method checks that the amount set by the user do not
        # increases the annual accumulated amount over the maximum allowed
        def maximum_user_amount
          return if amount.nil?
          return if annual_accumulated + amount <= Decidim::Collaborations.maximum_annual_collaboration

          errors.add(
            :amount,
            I18n.t(
              "amount.annual_limit_exceeded",
              amount: context.collaboration.minimum_custom_amount,
              scope: "activemodel.errors.models.user_collaboration.attributes"
            )
          )
        end

        def annual_accumulated
          Census::API::Totals.user_totals(context.current_user.id) || Decidim::Collaborations.maximum_annual_collaboration
        end
      end
    end
  end
end
