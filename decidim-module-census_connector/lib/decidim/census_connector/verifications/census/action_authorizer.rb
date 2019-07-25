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
            return [:missing, action: :authorize] unless authorization && person

            @status_code = :ok
            @data = {}
            authorize_state && authorize_age && authorize_document_type && authorize_census_closure && authorize_scope && authorize_verification

            check_service_status

            [@status_code, @data]
          end

          def redirect_params
            params = {}
            params[:minimum_age] = minimum_age if authorizing_by_age?
            params[:allowed_document_types] = allowed_document_types if authorizing_by_document_type?
            params[:allowed_scope] = current_scope.code if authorizing_by_scope?
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
            I18n.t("state.#{person.state}", scope: "census.api.person").downcase if person.state
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
            if unauthorized_closed_scope?
              unauthorized(:closed_scope)
            elsif incomplete_scope?
              incomplete(:scope)
            elsif unauthorized_scope?
              unauthorized(:scope)
            else
              true
            end
          end

          def unauthorized_closed_scope?
            authorizing_by_scope? && authorizing_by_census_closure? && current_scope && !current_scope.ancestor_of?(census_closure_person&.scope)
          end

          def incomplete_scope?
            authorizing_by_scope? && current_scope && !person&.scope
          end

          def unauthorized_scope?
            authorizing_by_scope? && current_scope && !current_scope.ancestor_of?(person&.scope)
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

          def check_service_status
            return true unless person_proxy&.service_status == false

            @status_code = :unauthorized
            @data.except! :action, :cancel
            set_explanation(context: "census.api.messages", key: "error")
            false
          end

          def unauthorized(explanation_key, explanation_params = {})
            @status_code = :unauthorized
            set_explanation(key: explanation_key, params: explanation_params)
            false
          end

          def not_enabled(explanation_key, explanation_params = {})
            @status_code = :not_enabled
            set_explanation(key: explanation_key, params: explanation_params)
            false
          end

          def incomplete(explanation_key, explanation_params = {})
            @status_code = :incomplete
            @data[:action] = :complete
            @data[:cancel] = true
            set_explanation(key: explanation_key, params: explanation_params)
            false
          end

          def not_verified(explanation_key, explanation_params = {})
            @status_code = :not_verified
            @data[:action] = :verify
            @data[:cancel] = true
            set_explanation(key: explanation_key, params: explanation_params)
            false
          end

          def set_explanation(key:, params: {}, context: "decidim.authorization_handlers.census.extra_explanation")
            @data[:extra_explanation] = { key: "#{context}.#{key}", params: params }
          end

          def current_scope
            @current_scope ||= resource&.try(:scope) ||
                               component.try(:scope) ||
                               component.participatory_space.try(:scope)
          end

          def person
            @person ||= person_proxy&.person
          end

          def person_proxy
            @person_proxy || Decidim::CensusConnector::PersonProxy.new(authorization) if authorization
          end

          def census_closure_person
            @census_closure_person ||= if authorizing_by_census_closure?
                                         Decidim::CensusConnector::PersonProxy.new(authorization, version_at: census_closure).person if authorization
                                       else
                                         person
                                       end
          end
        end
      end
    end
  end
end
