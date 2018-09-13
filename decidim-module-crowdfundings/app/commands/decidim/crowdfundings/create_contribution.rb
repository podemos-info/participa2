# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Rectify command that creates a contribution
    class CreateContribution < Rectify::Command
      # payments_proxy - A proxy object to access the census payments API
      # form - A Decidim::Form object.
      def initialize(payments_proxy, form)
        @payments_proxy = payments_proxy
        @form = form
      end

      # Creates the contribution if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) unless form.valid?

        create_order && create_contribution

        return broadcast(:credit_card, order_info[:form]) if result == :ok && form.credit_card_external?

        broadcast(result, order_info)
      end

      private

      attr_reader :form, :payments_proxy, :result, :order_info

      delegate :campaign, to: :form

      def create_order
        @result, @order_info = payments_proxy.create_order(order_parameters)

        Decidim::CensusConnector::ErrorConverter.new(form, order_info[:errors]).run if result == :invalid

        return false unless result == :ok

        form.payment_method_id = order_info[:payment_method_id] if order_info[:payment_method_id]

        true
      end

      def order_parameters
        params = {
          description: form.description,
          amount: form.amount,
          campaign_code: form.campaign_code,
          payment_method_type: form.payment_method_type
        }

        if form.credit_card_external?
          params[:return_url] = form.external_credit_card_return_url
        elsif form.existing_payment_method?
          params[:payment_method_id] = form.payment_method_id
        elsif form.direct_debit?
          params[:iban] = form.iban
        end

        params
      end

      def create_contribution
        Contribution.create(
          campaign: campaign,
          user: form.context.current_user,
          frequency: form.frequency,
          amount: form.amount,
          payment_method_id: form.payment_method_id,
          state: contribution_state,
          last_order_request_date: Time.zone.today.beginning_of_month
        )
        true
      end

      def contribution_state
        if form.credit_card_external?
          :pending
        else
          :accepted
        end
      end
    end
  end
end
