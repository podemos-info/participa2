# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # This class holds a Form to create a contribution
    class ContributionForm < UserProfile::ContributionForm
      attribute :payment_method_type, String

      validates :payment_method_type, presence: true

      Census::API::PaymentMethodDefinitions::TYPES.each do |type|
        define_method "#{type}?" do
          payment_method_type == type
        end
      end
    end
  end
end
