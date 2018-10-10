# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        # A command to complete a phone verification for a person.
        class PerformCensusPhoneVerificationStep < Rectify::Command
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

            create_phone_verification

            add_errors_to_form
            broadcast(result)
          end

          private

          attr_reader :form, :person_proxy, :result, :info

          def create_phone_verification
            @result, @info = person_proxy.create_phone_verification(phone_verification_params)
          end

          def add_errors_to_form
            ErrorConverter.new(form, info[:errors]).run if result == :invalid
          end

          def phone_verification_params
            {
              phone: phone,
              received_code: received_code
            }
          end

          delegate :received_code, :phone, to: :form
        end
      end
    end
  end
end
