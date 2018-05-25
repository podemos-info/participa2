# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        class DataForm < Decidim::Form
          delegate :local_scope, :person_proxy, :user, to: :context
          delegate :person, to: :person_proxy
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

          validates :first_name, :last_name1, :born_at, presence: true, unless: :verified?
          validates :document_type, inclusion: { in: Person.document_types.values }, unless: :verified?
          validates :document_id, format: { with: /\A[A-z0-9]*\z/, message: I18n.t("errors.messages.uppercase_only_letters_numbers") }, presence: true, unless: :verified?
          validates :document_scope_id, presence: true, unless: :local_document?
          validates :document_scope, presence: true, unless: :verified?
          validates :gender, inclusion: { in: Person.genders.values }, presence: true, unless: :verified?
          validates :postal_code, presence: true, format: { with: /\A[0-9]*\z/, message: I18n.t("errors.messages.uppercase_only_letters_numbers") }
          validates :scope_id, presence: true, unless: :local_address?
          validates :scope, :address, :address_scope_id, presence: true

          def document_type
            @document_type ||= Person.document_types.values.first
          end

          def document_scope_id
            @document_scope_id ||= local_scope.id
          end

          def document_scope
            @document_scope ||= begin
              if local_document?
                local_scope
              else
                Decidim::Scope.find_by(id: document_scope_id)
              end
            end
          end

          def address_scope
            @address_scope ||= Decidim::Scope.find_by(id: address_scope_id)
          end

          def scope
            @scope ||= begin
              if local_address?
                address_scope
              else
                Decidim::Scope.find_by(id: scope_id)
              end
            end
          end

          def local_document?
            Person.local_document?(document_type)
          end

          def local_address?
            local_scope.ancestor_of?(address_scope)
          end

          def verified?
            person&.verified?
          end
        end
      end
    end
  end
end
