# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Helper methods for contributions controller views.
    module ContributionsHelper
      # PUBLIC true if the form needs an IBAN field
      def iban_field?(form)
        form&.payment_method_type == "direct_debit"
      end

      # PUBLIC true if payment method selected already exists.
      def existing_payment_method?(form)
        form&.payment_method_type == "existing_payment_method"
      end

      def state_label(contribution_state)
        I18n.t("labels.contribution.states.#{contribution_state}", scope: "decidim.crowdfundings")
      end
    end
  end
end
