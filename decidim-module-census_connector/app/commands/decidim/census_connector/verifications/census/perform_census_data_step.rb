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
              add_errors_to_form

              broadcast :invalid
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
              form.errors.add(key, value) if form.respond_to?(key)
            end
          end

          def person_params
            {
              email: form.email,
              first_name: form.first_name,
              last_name1: form.last_name1,
              last_name2: form.last_name2,
              document_type: form.document_type,
              document_id: form.document_id,
              born_at: form.born_at,
              gender: form.gender,
              address: form.address,
              postal_code: form.postal_code,
              document_scope_code: document_scope&.code,
              scope_code: scope&.code,
              address_scope_code: address_scope&.code
            }
          end

          def origin_qualified_id
            "#{form.user.id}@decidim"
          end

          delegate :local_scope, to: :form

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
            form.local_document?
          end

          def local_address?
            local_scope.ancestor_of?(address_scope)
          end
        end
      end
    end
  end
end
