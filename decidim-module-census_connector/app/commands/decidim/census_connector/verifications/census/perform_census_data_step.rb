# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        # A command to save person data for a user.
        class PerformCensusDataStep < Rectify::Command
          # Public: Initializes the command.
          #
          # form - A Decidim::Form object.
          # person_proxy - A Decidim::CensusConnector::PersonProxy object
          def initialize(person_proxy, form)
            @person_proxy = person_proxy
            @form = form
          end

          # Executes the command. Broadcasts these events:
          #
          # - :ok when everything is valid.
          # - :invalid if the form wasn't valid and we couldn't proceed.
          # - :error when there were errors.
          #
          # Returns nothing.
          def call
            return broadcast(:invalid) if form.invalid?

            save_person
            start_phone_verification

            add_errors_to_form
            broadcast(result)
          end

          private

          attr_reader :form, :person_proxy, :result, :info

          def save_person
            @result = :ok
            return unless person_params.any?

            @result, @info = if person_proxy.has_person?
                               person_proxy.update(person_params)
                             else
                               person_proxy.create(person_params.merge(origin_qualified_id: origin_qualified_id))
                             end
          end

          def start_phone_verification
            return unless result == :ok && verify_phone?

            @result, @info = person_proxy.start_phone_verification(phone_verification_params)
          end

          def add_errors_to_form
            ErrorConverter.new(form, info[:errors], attribute_form_field_mappings).run if result == :invalid
          end

          def attribute_form_field_mappings
            {
              document_scope: :document_scope_id,
              address_scope: :address_scope_id,
              scope: :scope_id
            }
          end

          def person_params
            base = {}

            if personal_part?
              base.merge!(
                first_name: first_name,
                last_name1: last_name1,
                last_name2: last_name2,
                document_type: document_type,
                document_id: document_id,
                born_at: born_at,
                gender: gender
              )
            end

            if location_part?
              base.merge!(
                address: address,
                postal_code: postal_code,
                document_scope_code: document_scope_code,
                address_scope_code: address_scope_code,
                scope_code: scope_code
              )
            end

            # Only update phone when is not verifying it
            base[:phone] = phone if phone_part? && !phone_verification_required?

            base[:email] = user.email if base.any?

            base
          end

          def origin_qualified_id
            "#{user.id}@#{Rails.application.engine_name}-#{organization.id}"
          end

          delegate :user, to: :person_proxy
          delegate :organization, to: :user
          delegate :personal_part?, :location_part?, :phone_part?, :phone_verification_required?, :verify_phone?, :local_scope, to: :form
          delegate :first_name, :last_name1, :last_name2, :document_type, :document_id, to: :form
          delegate :born_at, :gender, :address, :postal_code, :phone, to: :form

          delegate :code, to: :document_scope, allow_nil: true, prefix: true
          delegate :code, to: :scope, allow_nil: true, prefix: true
          delegate :code, to: :address_scope, allow_nil: true, prefix: true

          def document_scope
            @document_scope ||= begin
              if local_document?
                local_scope
              else
                scopes.find_by(id: form.document_scope_id)
              end
            end
          end

          def address_scope
            @address_scope ||= scopes.find_by(id: form.address_scope_id)
          end

          def scope
            @scope ||= begin
              if local_address?
                address_scope
              else
                scopes.find_by(id: form.scope_id)
              end
            end
          end

          def local_document?
            Person.local_document?(document_type)
          end

          def local_address?
            local_scope.ancestor_of?(address_scope)
          end

          def scopes
            user.organization.scopes
          end

          def phone_verification_params
            {
              phone: phone
            }
          end
        end
      end
    end
  end
end
