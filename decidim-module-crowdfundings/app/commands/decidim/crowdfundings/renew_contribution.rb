# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Rectify command that renews a recurrent contribution
    class RenewContribution < Rectify::Command
      include Decidim::TranslationsHelper

      # payments_proxy - A proxy object to access the census payments API
      # contribution - A contribution to renew
      def initialize(payments_proxy, contribution)
        @payments_proxy = payments_proxy
        @contribution = contribution
      end

      # Renews the contribution if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) unless valid?

        create_order && renew_contribution

        broadcast(result, order_info)
      end

      private

      attr_reader :contribution, :payments_proxy, :result, :order_info

      delegate :campaign, to: :contribution

      def valid?
        campaign.accepts_contributions? && payments_proxy.under_annual_limit?(add_amount: contribution.amount)
      end

      def create_order
        @result, @order_info = payments_proxy.create_order(order_parameters)
        result == :ok
      end

      def order_parameters
        {
          description: campaign.title[Decidim.default_locale],
          amount: contribution.amount,
          campaign_code: campaign.reference,
          payment_method_type: "existing_payment_method",
          payment_method_id: contribution.payment_method_id
        }
      end

      def renew_contribution
        contribution.update(
          last_order_request_date: Time.zone.today.beginning_of_month
        )
      end
    end
  end
end
