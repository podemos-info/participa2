# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Rectify command that refresh a pending contribution
    class RefreshContribution < Rectify::Command
      # payments_proxy - A proxy object to access the census payments API
      # contribution - A contribution to check
      def initialize(payments_proxy, contribution)
        @payments_proxy = payments_proxy
        @contribution = contribution
      end

      # Creates the contribution if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) unless payment_method

        refresh_contribution_status
        broadcast(:ok)
      end

      private

      attr_reader :contribution, :payments_proxy

      def refresh_contribution_status
        return if payment_method.incomplete?

        contribution.update!(state: payment_method.active? ? :accepted : :rejected)
      end

      def payment_method
        @payment_method ||= payments_proxy.payment_method(contribution.payment_method_id)
      end
    end
  end
end
