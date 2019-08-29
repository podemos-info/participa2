# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # This class holds a Form to create a contribution
    class ContributionForm < UserProfile::ContributionForm
      attribute :payment_method_type, String

      validates :payment_method_type, presence: true

      validate :allowed_payment_method_type

      Census::API::PaymentMethodDefinitions::TYPES.each do |type|
        define_method "#{type}?" do
          payment_method_type == type
        end
      end

      def allowed_payment_method_type
        return if payment_method_type.match?(/\A\d+\z/) ||
                  Decidim::Crowdfundings.enabled_payment_methods.member?(payment_method_type)

        errors.add(
          :payment_method_type,
          I18n.t(
            "payment_method_type.invalid",
            scope: "activemodel.errors.models.contribution.attributes"
          )
        )
      end
    end
  end
end
