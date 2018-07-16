# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        # A command to create a partial authorization for a user.
        class PerformCensusMembershipLevelStep < PerformCensusStep
          def perform
            result = update_membership_level

            if result
              broadcast :ok
            else
              broadcast :invalid, census_person_api.global_error
            end
          end

          private

          def update_membership_level
            census_person_api.create_membership_level(membership_level_params)
          end

          def membership_level_params
            {
              membership_level: form.level
            }
          end
        end
      end
    end
  end
end
