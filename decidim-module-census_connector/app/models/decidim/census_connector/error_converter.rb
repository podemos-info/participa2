# frozen_string_literal: true

module Decidim
  module CensusConnector
    #
    # Adds an error hash coming from the API to a form
    #
    class ErrorConverter
      #
      # @param form [Decidim::Form] the target form
      # @param errors [Hash] the error hash
      # @param attribute_mapping [Hash] the attribute mapping. If there's no
      #   mapping for an attribute, the same name will be used.
      #
      def initialize(form, errors, attribute_mapping = {})
        @form = form
        @errors = errors
        @attribute_mapping = attribute_mapping
      end

      def run
        errors.each do |attribute, errors|
          errored_attribute = attribute_mapping[attribute] || attribute
          next unless errored_attribute

          errors.each do |error_hash|
            error_type = error_hash.delete(:error)

            form.errors.add(errored_attribute, error_type.to_sym, error_hash)
          end
        end
      end

      private

      attr_reader :form, :errors, :attribute_mapping
    end
  end
end
