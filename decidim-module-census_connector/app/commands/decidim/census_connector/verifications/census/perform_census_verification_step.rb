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
              broadcast :invalid, formatted_error
            end
          end

          private

          def formatted_error
            if census_person.errors
              census_person.errors.map { |key, value| "#{key}: #{value.join(", ")}" }
            else
              census_person.global_error
            end
          end

          def create_verification
            census_person.create_verification(verification_params)
          end

          def verification_params
            {
              files: form.files
            }
          end
        end
      end
    end
  end
end
