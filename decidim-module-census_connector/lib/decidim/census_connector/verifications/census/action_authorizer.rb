# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        class ActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
          def self.describe_options(options)
            ActionAuthorizerOptions.new(options).descriptions
          end

          def authorize
            return [:missing, action: :authorize] unless authorization

            @status_code = :ok
            @data = {}
            authorize_state && authorize_age && authorize_document_type && authorize_census_closure && authorize_scope && authorize_verification

            [@status_code, @data]
          end

          def redirect_params
            params = {}
            params[:minimum_age] = minimum_age if authorizing_by_age?
            params[:allowed_document_types] = allowed_document_types if authorizing_by_document_type?
            params[:allowed_scope] = component_scope.code if authorizing_by_scope?
            params[:census_closure] = census_closure if authorizing_by_census_closure?
            params[:allowed_verifications] = allowed_verification_levels if authorizing_by_verification?

            params[:step] = if @status_code == :not_verified
                              "verification"
                            else
                              "data"
                            end
            params
          end

          private

          delegate :authorizing_by_age?, :minimum_age, to: :census_options
          delegate :authorizing_by_document_type?, :allowed_document_types, :humanized_allowed_document_types, to: :census_options
          delegate :authorizing_by_census_closure?, :humanized_census_closure, :census_closure, to: :census_options
          delegate :authorizing_by_verification?, :allowed_verification_levels, :minimum_verification_level, to: :census_options

          def census_options
            @census_options ||= ActionAuthorizerOptions.new(options)
          end

          def authorize_state
            return not_enabled(:state, state: humanized_state) unless person.enabled?
            true
          end

          def humanized_state
            I18n.t("state.#{person.state}", scope: "census.api.person").downcase
          end

          def authorize_age
            return unauthorized(:age, minimum_age: minimum_age) if authorizing_by_age? && person.age < minimum_age
            true
          end

          def authorize_document_type
            return unauthorized(:document_type, allowed_document_types: humanized_allowed_document_types) if authorizing_by_document_type? &&
                                                                                                             !allowed_document_types.include?(person.document_type)
            true
          end

          def authorize_scope
            return unauthorized(:closed_scope) if authorizing_by_scope? && authorizing_by_census_closure? && current_scope &&
                                                  current_scope.ancestor_of?(census_closure_person&.scope)
            return incomplete(:scope) if authorizing_by_scope? && current_scope && current_scope.ancestor_of?(person&.scope)
            true
          end

          def authorize_census_closure
            return unauthorized(:census_closure, census_closure: humanized_census_closure) if authorizing_by_census_closure? && !census_closure_person&.enabled?
            true
          end

          def authorize_verification
            return not_verified(minimum_verification_level) if authorizing_by_verification? && !allowed_verification_levels.include?(person.verification)
            true
          end

          def authorizing_by_scope?
            census_options.authorizing_by_scope? && current_scope
          end

          def unauthorized(explanation_key, explanation_params = {})
            @status_code = :unauthorized
            add_explanation(explanation_key, explanation_params)
            false
          end

          def not_enabled(explanation_key, explanation_params = {})
            @status_code = :not_enabled
            add_explanation(explanation_key, explanation_params)
            false
          end

          def incomplete(explanation_key, explanation_params = {})
            @status_code = :incomplete
            @data[:action] = :complete
            @data[:cancel] = true
            add_explanation(explanation_key, explanation_params)
            false
          end

          def not_verified(explanation_key, explanation_params = {})
            @status_code = :not_verified
            @data[:action] = :verify
            @data[:cancel] = true
            add_explanation(explanation_key, explanation_params)
            false
          end

          def add_explanation(explanation_key, explanation_params)
            @data[:extra_explanation] = { key: "decidim.authorization_handlers.census.extra_explanation.#{explanation_key}", params: explanation_params }
          end

          def current_scope
            @current_scope ||= resource&.try(:scope) ||
                               component.try(:scope) ||
                               component.participatory_space.try(:scope)
          end

          def person
            @person ||= Decidim::CensusConnector::PersonProxy.new(authorization)&.person if authorization
          end

          def census_closure_person
            @census_closure_person ||= if authorizing_by_census_closure?
                                         Decidim::CensusConnector::PersonProxy.new(authorization, version_at: census_closure)&.person if authorization
                                       else
                                         person
                                       end
          end
        end
      end
    end
  end
end
