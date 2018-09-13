# frozen_string_literal: true

module Decidim
  module Crowdfundings
    class PaymentsProxy
      def initialize(person_proxy = nil)
        @person_proxy = person_proxy
      end

      def person_proxy=(person_proxy)
        @person_proxy = person_proxy
        remove_instance_variable :@person_annual_total if defined? @person_annual_total
        @payment_methods = @person_campaign_total = @contribution_error = nil
      end

      delegate :user, :has_person?, to: :person_proxy, allow_nil: true

      # no person required methods

      def campaign_total(campaign)
        @campaign_total ||= Hash.new do |h, key|
          h[key] = census_payments_api.if_valid(census_payments_api.orders_total(campaign_code: key))
        end
        @campaign_total[campaign.reference]
      end

      def payment_method(payment_method_id)
        census_payments_api.if_valid(census_payments_api.payment_method(payment_method_id))
      end

      # person required methods

      def create_order(**params)
        census_payments_api.create_order(qualified_id, **params)
      end

      def payment_methods
        @payment_methods ||= census_payments_api.if_valid(census_payments_api.payment_methods(qualified_id))
      end

      def person_campaign_total(campaign)
        @person_campaign_total ||= Hash.new do |h, key|
          h[key] = census_payments_api.if_valid(census_payments_api.orders_total(person_id: qualified_id, campaign_code: key))
        end
        @person_campaign_total[campaign.reference]
      end

      def under_annual_limit?(add_amount: 0)
        person_annual_total + add_amount < Decidim::Crowdfundings.maximum_annual_contribution_amount if person_annual_total
      end

      def contribution_error
        @contribution_error ||= begin
          if person_proxy&.has_person? && under_annual_limit? == false
            :maximum_annual_exceeded
          elsif census_payments_api.service_status == false
            :service_unavailable
          else
            false
          end
        end
      end

      private

      attr_reader :person_proxy

      def person_annual_total
        return @person_annual_total if defined? @person_annual_total
        @person_annual_total ||= census_payments_api.if_valid(
          census_payments_api.orders_total(person_id: qualified_id, from_date: Time.zone.now.beginning_of_year, until_date: Time.zone.now.end_of_year)
        )
      end

      def census_payments_api
        @census_payments_api ||= ::Census::API::Payments.new
      end

      def qualified_id
        raise "Person ID not available" unless person_proxy&.has_person?

        "#{person_proxy.person_id}@census"
      end
    end
  end
end
