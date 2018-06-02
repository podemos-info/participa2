# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        class ActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
          def authorize
            @allowed_document_types = options.delete("allowed_document_types")
            @minimum_age = options.delete("minimum_age")

            @status_code, @data = *super

            return [@status_code, @data] if @status_code == :missing

            authorize_age

            authorize_document_type

            authorize_state

            add_extra_explanation unless [:ok, :pending].include?(@status_code)

            [@status_code, @data]
          end

          def redirect_params
            params = {}
            params[:minimum_age] = minimum_age if authorizing_by_age?
            params[:allowed_documents] = humanized_allowed_documents if authorizing_by_document_type?
            params
          end

          private

          def authorizing_by_age?
            minimum_age.present?
          end

          def authorizing_by_document_type?
            allowed_document_types.present?
          end

          def authorizing_by_age_and_document_type?
            authorizing_by_age? && authorizing_by_document_type?
          end

          def authorizing_by_age_or_document_type?
            authorizing_by_age? || authorizing_by_document_type?
          end

          def authorize_age
            return unless authorizing_by_age? && age < minimum_age

            add_authorization_error("age", age)
          end

          def authorize_document_type
            return unless authorizing_by_document_type? && !allowed_document_types.include?(document_type)

            add_authorization_error("document_type", document_type_label)
          end

          def authorize_state
            if @status_code == :unauthorized
              # Due to current authorizations implementation details, pending
              # authorizations are not "granted in DB", whereas unauthorized ones
              # are. So we need to force the authorization to be granted in order
              # for decidim UI to properly display authorization errors instead of
              # a "pending authorization" modal. This is a hacky-not-good-enough
              # solution we should iterate over
              authorization.grant!
            elsif person.enabled?
              @status_code = :ok

              authorization.grant!
            else
              authorization.update!(granted_at: nil)
            end
          end

          def add_authorization_error(field, error)
            @status_code = :unauthorized

            add_unmatched_field(field => error)
          end

          def add_extra_explanation
            return unless authorizing_by_age_or_document_type?

            @data[:extra_explanation] = {
              key: extra_explanation_key,
              params: extra_explanation_params
            }
          end

          def extra_explanation_key
            if authorizing_by_age_and_document_type?
              "extra_explanation_age_and_document_type"
            elsif authorizing_by_age?
              "extra_explanation_age"
            else
              "extra_explanation_document_type"
            end
          end

          def extra_explanation_params
            redirect_params.merge(scope: "decidim.census_connector.verifications.census")
          end

          def humanized_allowed_documents
            allowed_document_types.to_sentence(
              words_connector: " #{I18n.t("or", scope: "decidim.census_connector.verifications.census")} "
            )
          end

          def add_unmatched_field(field)
            @data[:fields] ||= {}

            @data[:fields].merge!(field)
          end

          def document_type_label
            I18n.t(document_type, scope: "census.api.person.document_type")
          end

          attr_reader :allowed_document_types

          def minimum_age
            @minimum_age&.to_i
          end

          delegate :age, :document_type, to: :person

          def person
            @person ||= Decidim::CensusConnector::PersonProxy.new(authorization)&.person if authorization
          end
        end
      end
    end
  end
end
