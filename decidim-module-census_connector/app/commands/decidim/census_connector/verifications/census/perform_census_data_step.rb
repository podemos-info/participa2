# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        # A command to create a partial authorization for a user.
        class PerformCensusDataStep < PerformCensusStep
          def perform
            result = if has_no_person?
                       create_person
                     else
                       update_person
                     end

            if result
              broadcast :ok
            else
              add_errors_to_form if census_person.errors

              broadcast :invalid, census_person.global_error
            end
          end

          private

          def create_person
            result = census_person.create(person_params.merge(origin_qualified_id: origin_qualified_id))

            authorization.update!(metadata: { "person_id" => census_person.person_id }) if result

            result
          end

          def update_person
            census_person.update(person_params)
          end

          def add_errors_to_form
            census_person.errors.each do |key, value|
              if key.match?(/scope\Z/)
                form.errors.add("#{key}_id", value)
              elsif form.respond_to?(key)
                form.errors.add(key, value)
              end
            end
          end

          def person_params
            base = {
              email: email,
              first_name: first_name,
              last_name1: last_name1,
              last_name2: last_name2,
              document_type: document_type,
              document_id: document_id,
              born_at: born_at,
              gender: gender,
              address: address,
              postal_code: postal_code,
              document_scope_code: document_scope_code,
              address_scope_code: address_scope_code
            }

            base[:scope_code] = scope_code if address_scope.present?

            base
          end

          def origin_qualified_id
            "#{form.user.id}@decidim"
          end

          delegate :local_scope, to: :form
          delegate :email, :first_name, :last_name1, :last_name2, :document_type, :document_id, :born_at, :gender, :address, :postal_code, to: :form

          delegate :code, to: :document_scope, allow_nil: true, prefix: true
          delegate :code, to: :scope, allow_nil: true, prefix: true
          delegate :code, to: :address_scope, allow_nil: true, prefix: true

          def document_scope
            @document_scope ||= begin
              if local_document?
                local_scope
              else
                Decidim::Scope.find_by(id: form.document_scope_id)
              end
            end
          end

          def address_scope
            @address_scope ||= Decidim::Scope.find_by(id: form.address_scope_id)
          end

          def scope
            @scope ||= begin
              if local_address?
                address_scope
              else
                Decidim::Scope.find_by(id: form.scope_id)
              end
            end
          end

          def local_document?
            Person.local_document?(document_type)
          end

          def local_address?
            local_scope.ancestor_of?(address_scope)
          end
        end
      end
    end
  end
end
