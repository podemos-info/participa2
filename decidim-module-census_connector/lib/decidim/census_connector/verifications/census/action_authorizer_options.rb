# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        class ActionAuthorizerOptions
          def initialize(options)
            @allowed_document_types = options["allowed_document_types"]
            @minimum_age = options["minimum_age"]
            @census_closure = options["census_closure"]
            @allowed_verification_levels = options["allowed_verification_levels"]
            @enforce_scope = options["enforce_scope"]
          end

          def descriptions
            descriptions = {}
            descriptions[:calendar] = field_description("minimum_age", minimum_age: minimum_age) if authorizing_by_age?
            descriptions[:flag] = field_description("document_type", allowed_document_types: humanized_allowed_document_types) if authorizing_by_document_type?
            descriptions[:"lock-locked"] = field_description("census_closure", census_closure: humanized_census_closure) if authorizing_by_census_closure?
            descriptions[:task] = field_description("verification") if authorizing_by_verification?
            descriptions
          end

          def authorizing_by_age?
            @minimum_age.present?
          end

          def authorizing_by_document_type?
            @allowed_document_types.present?
          end

          def authorizing_by_census_closure?
            @census_closure.present?
          end

          def authorizing_by_scope?
            @enforce_scope
          end

          def authorizing_by_verification?
            @allowed_verification_levels.present?
          end

          def humanized_allowed_document_types
            allowed_document_types.map do |document_type|
              I18n.t("document_type.#{document_type}", scope: "census.api.person")
            end.to_sentence(
              two_words_connector: " #{I18n.t("or", scope: "decidim.census_connector.verifications.census")} "
            )
          end

          def humanized_census_closure
            I18n.l(census_closure, format: :long)
          end

          def minimum_verification_level
            if allowed_verification_levels.include?("verification_received")
              :verification_received
            else
              :verification
            end
          end

          def minimum_age
            @minimum_age&.to_i
          end

          def allowed_document_types
            @allowed_document_types.split(",").map(&:strip)
          end

          def allowed_verification_levels
            @allowed_verification_levels.split(",").map(&:strip)
          end

          def census_closure
            Time.zone.parse(@census_closure)
          end

          private

          def field_description(field, params = {})
            I18n.t("descriptions.#{field}", scope: "decidim.census_connector.verifications.census", **params)
          end
        end
      end
    end
  end
end
