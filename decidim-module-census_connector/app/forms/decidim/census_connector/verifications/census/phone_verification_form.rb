# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        class PhoneVerificationForm < Decidim::Form
          attribute :received_code, String

          def full_process?
            part.blank?
          end

          def action
            :verify
          end

          def pretty_phone
            "(+#{parsed_phone.country_code}) #{parsed_phone.national}"
          end

          def phone
            params[:phone] || person.phone
          end

          def next_step
            :verification if full_process?
          end

          def next_step_params
            { part: part }
          end

          private

          delegate :person, :params, to: :context

          def parsed_phone
            @parsed_phone ||= Phonelib.parse(phone)
          end

          def part
            @part ||= params[:part]
          end
        end
      end
    end
  end
end
