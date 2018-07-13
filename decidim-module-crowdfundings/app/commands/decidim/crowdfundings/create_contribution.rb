# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Rectify command that creates a contribution
    class CreateContribution < Rectify::Command
      include Decidim::TranslationsHelper

      attr_reader :form

      def initialize(form)
        @form = form
      end

      # Creates the contribution if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if form.invalid?
        census_result = process_contribution
        case census_result[:http_response_code]
        when 201
          broadcast(:ok)
        when 202
          broadcast(:credit_card, census_result)
        else
          broadcast(:invalid)
        end
      end

      private

      def process_contribution
        result = register_on_census
        create_contribution result[:payment_method_id] if result[:http_response_code].between?(201, 202)

        result
      end

      def register_on_census
        Census::API::Order.create(census_parameters)
      end

      def census_parameters
        params = {
          person_id: form.context.current_user.id,
          description: translated_attribute(form.context.campaign.title),
          amount: form.amount * 100,
          campaign_code: form.context.campaign.id,
          payment_method_type: form.payment_method_type
        }

        if form.credit_card_external?
          params[:return_url] = validate_contribution_url(
            form.context.campaign, result: "__RESULT__"
          )
        end

        params[:payment_method_id] = form.payment_method_id if form.existing_payment_method?

        params[:iban] = form.iban if form.direct_debit?
        params
      end

      def create_contribution(payment_method_id = nil)
        Contribution.create(
          campaign: form.context.campaign,
          user: form.context.current_user,
          frequency: form.frequency,
          amount: form.amount,
          payment_method_id: payment_method_id || form.payment_method_id,
          state: contribution_state,
          last_order_request_date: Time.zone.today.beginning_of_month
        )
      end

      def contribution_state
        return "pending" if form.credit_card_external?
        "accepted"
      end
    end
  end
end
