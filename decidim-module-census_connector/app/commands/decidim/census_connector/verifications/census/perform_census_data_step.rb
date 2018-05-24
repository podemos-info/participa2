# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        # A command to create a partial authorization for a user.
        class PerformCensusDataStep < PerformCensusStep
          def perform
            if has_no_person?
              person_id = ::Census::API::Person.create(person_params.merge(origin_qualified_id: origin_qualified_id))

              authorization.update!(metadata: { "person_id" => person_id })
            else
              census_person.update(person_params)
            end

            broadcast :ok
          end

          private

          def person_params
            attributes.except(:document_scope_id, :scope_id, :address_scope_id).merge(
              email: handler.user.email,
              document_scope_code: handler.document_scope&.code,
              scope_code: handler.scope&.code,
              address_scope_code: handler.address_scope&.code
            )
          end

          def origin_qualified_id
            "#{handler.user.id}@decidim"
          end
        end
      end
    end
  end
end
