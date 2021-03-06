# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Helper methods for crowdfundings campaigns controller views.
    module CampaignsHelper
      # Formats a number as a currency following the conventions and
      # settings predefined in the platform.d
      def decidim_number_to_currency(number)
        number_to_currency(number.nil? ? 0 : number,
                           unit: Decidim.currency_unit,
                           format: "%n %u")
      end

      # PUBLIC returns a list of frequency options that can be used
      # in a select input tag.
      def frequency_options
        frequency_selector(Contribution.frequencies)
      end

      # PUBLIC returns a list of recurrent frequency options that can be used
      # in a select input tag.
      def recurrent_frequency_options
        frequency_selector(Contribution.recurrent_frequencies)
      end

      # PUBLIC Human readable frequency value
      def frequency_label(frequency)
        I18n.t("labels.frequencies.#{frequency}", scope: "decidim.crowdfundings")
      end

      # PUBLIC returns a list of payment method type options that can
      # be used in a select input tag.
      def new_payment_method_options
        Decidim::Crowdfundings.enabled_payment_methods.map do |type|
          [payment_method_label(type), type]
        end
      end

      # PUBLIC Human readable payment method type value
      def payment_method_label(type)
        I18n.t("labels.payment_method_types.#{type}", scope: "decidim.crowdfundings")
      end

      private

      def frequency_selector(frequencies)
        frequencies.map do |frequency|
          [frequency_label(frequency[0]), frequency[0]]
        end
      end
    end
  end
end
