# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # This class holds a Form to confirm contributions
    class ConfirmContributionForm < ContributionForm
      mimic :contribution

      attribute :iban, String
      attribute :payment_method_id, Integer
      attribute :accept_terms_and_conditions, Boolean
      attribute :external_credit_card_return_url, String

      validates :iban, iban: true, presence: true, if: :direct_debit?
      validates :payment_method_id, presence: true, if: :existing_payment_method?
      validates :external_credit_card_return_url, presence: true, if: :credit_card_external?
      validates :accept_terms_and_conditions, presence: true

      def fix_payment_method
        return unless payment_method_type.match?(/\A\d+\z/)
        @payment_method_id = payment_method_type.to_i
        @payment_method_type = "existing_payment_method"
      end

      def payment_method
        @payment_method ||= payments_proxy.payment_method(payment_method_id)
      end
    end
  end
end
