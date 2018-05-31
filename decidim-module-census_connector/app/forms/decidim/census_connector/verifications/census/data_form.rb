# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        class DataForm < Decidim::Form
          delegate :local_scope, :user, to: :context
          delegate :email, to: :user

          attribute :first_name, String
          attribute :last_name1, String
          attribute :last_name2, String

          attribute :document_type, String
          attribute :document_id, String
          attribute :document_scope_id, Integer

          attribute :born_at, Date
          attribute :gender, String

          attribute :address, String
          attribute :address_scope_id, Integer
          attribute :scope_id, Integer
          attribute :postal_code, String

          def document_type
            @document_type ||= Person.document_types.values.first
          end

          def document_scope_id
            @document_scope_id ||= local_scope.id
          end
        end
      end
    end
  end
end
