# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        # A command to create a partial authorization for a user.
        class PerformCensusVerificationStep < PerformCensusStep
          def perform
            create_verification
            broadcast :ok
          end

          private

          def create_verification
            census_person.create_verification(verification_params)
          end

          def verification_params
            {
              files: [form.document_file1, form.document_file2]
            }
          end
        end
      end
    end
  end
end
