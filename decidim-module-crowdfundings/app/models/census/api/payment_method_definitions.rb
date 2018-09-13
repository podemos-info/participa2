# frozen_string_literal: true

require "active_support/concern"

module Census
  module API
    # Container module for Census API payment method constants
    module PaymentMethodDefinitions
      extend ActiveSupport::Concern

      TYPES = %w(existing_payment_method direct_debit credit_card_external).freeze
      STATUS = %w(incomplete active inactive).freeze
    end
  end
end
