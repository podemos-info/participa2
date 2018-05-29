# frozen_string_literal: true

module Decidim
  module Collaborations
    # Calls that interact with Census API
    module CensusAPI
      extend ActiveSupport::Concern

      included do
        helper_method :user_payment_methods, :user_payment_method

        private

        def user_payment_methods
          ::Census::API::PaymentMethod.for_user(current_user&.id)
        end

        def user_payment_method(payment_method_id)
          payment_methods = ::Census::API::PaymentMethod
                            .for_user(current_user&.id)
                            .map { |m| [m[:id], m] }
                            .to_h

          payment_methods[payment_method_id][:name]
        end
      end
    end
  end
end
