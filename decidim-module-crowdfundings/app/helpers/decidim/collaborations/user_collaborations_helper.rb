# frozen_string_literal: true

module Decidim
  module Collaborations
    # Helper methods for user collaboration controller views.
    module UserCollaborationsHelper
      # PUBLIC true if the form needs an IBAN field
      def iban_field?(form)
        form&.payment_method_type == "direct_debit"
      end

      # PUBLIC true if payment method selected already exists.
      def existing_payment_method?(form)
        form&.payment_method_type == "existing_payment_method"
      end
    end
  end
end
