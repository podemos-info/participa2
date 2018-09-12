# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        # A command to create a partial authorization for a user.
        class PerformCensusMembershipLevelStep < Rectify::Command
          # Public: Initializes the command.
          #
          # form - A Decidim::Form object.
          # person_proxy - A Decidim::CensusConnector::PersonProxy object
          def initialize(person_proxy, form)
            @person_proxy = person_proxy
            @form = form
          end

          # Executes the command. Broadcasts these events:
          #
          # - :ok when everything is valid.
          # - :invalid if the form wasn't valid and we couldn't proceed.
          # - :error when there were errors.
          #
          # Returns nothing.
          def call
            return broadcast(:invalid) if form.invalid?

            update_membership_level
            broadcast(result)
          end

          private

          attr_reader :form, :person_proxy, :result, :info

          def update_membership_level
            @result, @info = person_proxy.create_membership_level(membership_level_params)
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
