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
            person.create_membership_level(membership_level_params)
          end

          def membership_level_params
            attributes
          end
        end
      end
    end
  end
end
