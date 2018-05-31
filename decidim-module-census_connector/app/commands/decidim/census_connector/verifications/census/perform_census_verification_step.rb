# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        # A command to create a partial authorization for a user.
        class PerformCensusVerificationStep < PerformCensusStep
          def perform
            result = create_verification

            if result
              broadcast :ok
            else
              broadcast :invalid, formatted_errors
            end
          end

          private

          def formatted_errors
            census_person.errors.map { |key, value| "#{key}: #{value.join(", ")}" }
          end

          def create_verification
            census_person.create_verification(verification_params)
          end

          def verification_params
            {
              files: [form.document_file1, form.document_file2].compact
            }
          end
        end
      end
    end
  end
end
