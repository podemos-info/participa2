# frozen_string_literal: true

module Decidim
  module CensusConnector
    module AuthorizationsHelper
      def document_country_options(document_scopes)
        document_scopes.map { |scope| [translated_attribute(scope.name), scope.id] }
      end

      def phone_country_options(phone_scopes)
        [["- #{I18n.t("decidim.census_connector.verifications.census.authorizations.data.other_phone_country")} (+__)", ""]] +
          phone_scopes.map do |scope, phone_info|
            ["#{translated_attribute(scope.name)} (+#{phone_info[:country_code]})", phone_info[:id]]
          end
      end
    end
  end
end
