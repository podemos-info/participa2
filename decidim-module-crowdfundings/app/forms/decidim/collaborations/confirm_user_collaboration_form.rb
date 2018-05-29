# frozen_string_literal: true

module Decidim
  module Collaborations
    # This class holds a Form to confirm user collaborations
    class ConfirmUserCollaborationForm < UserCollaborationForm
      mimic :user_collaboration

      attribute :iban, String
      attribute :payment_method_id, Integer

      validates :iban, presence: true, if: :direct_debit?
      validates :iban, iban: true, unless: proc { |form| form.iban.blank? }
      validates :payment_method_id, presence: true, if: :existing_payment_method?

      def correct_payment_method
        return unless payment_method_type.match?(/\A\d+\z/)
        self.payment_method_id = payment_method_type.to_i
        self.payment_method_type = "existing_payment_method"
      end

      def existing_payment_method?
        payment_method_type == "existing_payment_method"
      end

      def direct_debit?
        payment_method_type == "direct_debit"
      end

      def credit_card_external?
        payment_method_type == "credit_card_external"
      end
    end
  end
end
