# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        class DataForm < Decidim::Form
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

          attribute :phone_country, String
          attribute :phone_number, String
          attribute :verify_phone, Boolean

          def map_model(person)
            phone_info = Phonelib.parse(person.phone)
            @phone_country = phone_info.country
            @phone_number = phone_info.national(false)
          end

          def phone_country
            @phone_country ||= Decidim::CensusConnector.census_local_code
          end

          def phone
            "#{self.class.international_prefix}#{country_code}#{phone_number}"
          end

          def self.international_prefix
            @international_prefix ||= Phonelib.phone_data[Decidim::CensusConnector.census_local_code][:international_prefix]
          end

          def document_type
            @document_type ||= Person.document_types.values.first
          end

          def document_scope_id
            @document_scope_id ||= local_scope.id
          end

          def full_process?
            part.blank?
          end

          def personal_part?
            !verified? && (full_process? || part == "personal")
          end

          def location_part?
            full_process? || part == "location"
          end

          def phone_part?
            full_process? || part == "phone"
          end

          def phone_verification_part?
            part == "phone_verification"
          end

          def phone_verification_required?
            phone_verified? || phone_verification_part?
          end

          def verify_phone?
            verify_phone || phone_verification_required?
          end

          def action
            if phone_verification_required?
              :start_phone_verification
            elsif full_process?
              :create
            else
              :update
            end
          end

          def next_step
            @next_step ||= if verify_phone?
                             :phone_verification
                           elsif full_process?
                             :verification
                           end
          end

          def next_step_params
            @next_step_params ||= begin
              ret = { part: part }
              ret[:phone] = phone if next_step == :phone_verification
              ret
            end
          end

          def pretty_phone
            "(+#{parsed_phone.country_code}) #{parsed_phone.national}"
          end

          private

          delegate :person, :local_scope, :params, to: :context

          def parsed_phone
            @parsed_phone ||= Phonelib.parse(phone)
          end

          def country_code
            @country_code ||= Phonelib.phone_data.dig(@phone_country, :country_code)
          end

          def verified?
            @verified ||= person&.verified?
          end

          def phone_verified?
            @phone_verified ||= person&.verified_phone?
          end

          def part
            @part ||= params[:part]
          end
        end
      end
    end
  end
end
