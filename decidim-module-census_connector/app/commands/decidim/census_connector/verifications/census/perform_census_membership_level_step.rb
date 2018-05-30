# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        # A command to create a partial authorization for a user.
        class PerformCensusMembershipLevelStep < PerformCensusStep
          def perform
            update_membership_level
            broadcast :ok
          end

          private

          def update_membership_level
            census_person.create_membership_level(membership_level_params)
          end

          def membership_level_params
            {
              membership_level: form.membership_level
            }
          end
        end
      end
    end
  end
end
