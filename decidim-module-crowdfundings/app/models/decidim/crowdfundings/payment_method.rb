# frozen_string_literal: true

module Decidim
  module Crowdfundings
    class PaymentMethod
      include Census::API::PaymentMethodDefinitions

      delegate :id, :name, :type, :status, :verified?, to: :payment_method_data

      def initialize(payment_method_data)
        @payment_method_data = OpenStruct.new(payment_method_data)
      end

      {
        type: TYPES,
        status: STATUS
      }.each do |attribute, values|
        values.each do |value|
          define_method "#{value}?" do
            @payment_method_data[attribute] == value
          end
        end
      end

      private

      attr_reader :payment_method_data
    end
  end
end
