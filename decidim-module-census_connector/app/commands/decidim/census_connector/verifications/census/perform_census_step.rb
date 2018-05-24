# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        # A command to create a partial authorization for a user.
        class PerformCensusStep < Rectify::Command
          # Public: Initializes the command.
          #
          # authorization - An Authorization object.
          # form - A Decidim::Form object.
          def initialize(authorization, form)
            @authorization = authorization
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
            @census_person ||= ::Census::API::Person.new(person_proxy.person_id)
          end

          def has_no_person?
            !person_proxy.has_person?
          end

          def person_proxy
            form.context.person_proxy
          end

          def attributes
            form.attributes.except(:user, :handler_name)
          end

          attr_reader :authorization, :form
        end
      end
    end
  end
end
