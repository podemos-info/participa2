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
            person.create_verification(verification_params)
          end

          def verification_params
            {
              files: attributes.fetch_values(:document_file1, :document_file2)
            }
          end
        end
      end
    end
  end
end
