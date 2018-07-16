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
              add_errors_to_form if census_person_api.errors

              broadcast :invalid, formatted_error
            end
          end

          private

          def add_errors_to_form
            ErrorConverter.new(form, census_person_api.errors).run
          end

          def formatted_error
            if census_person_api.errors
              form.errors.full_messages.join(", ")
            else
              census_person_api.global_error
            end
          end

          def create_verification
            census_person_api.create_verification(verification_params)
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
