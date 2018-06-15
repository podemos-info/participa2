# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        # A command to create a partial authorization for a user.
        class PerformCensusStep < Rectify::Command
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
          #
          # Returns nothing.
          def call
            return broadcast(:invalid) if form.invalid?

            perform
          end

          private

          def census_person
            person_proxy.census_person_api_connection
          end

          def has_no_person?
            !person_proxy.has_person?
          end

          attr_reader :form, :person_proxy

          delegate :authorization, to: :person_proxy
        end
      end
    end
  end
end
