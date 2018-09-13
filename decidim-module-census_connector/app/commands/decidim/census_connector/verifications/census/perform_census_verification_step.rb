# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        # A command to create a partial authorization for a user.
        class PerformCensusVerificationStep < Rectify::Command
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

            create_verification
            add_errors_to_form
            broadcast(result)
          end

          private

          attr_reader :form, :person_proxy, :result, :info

          def create_verification
            @result, @info = person_proxy.create_verification(verification_params)
          end

          def add_errors_to_form
            return unless result == :invalid

            form.errors.add(:document_file1, :empty) if minimum_files.positive? && submitted_files < minimum_files
            form.errors.add(:document_file2, :empty) if minimum_files > 1 && submitted_files < minimum_files
          end

          def verification_params
            {
              files: form.files
            }
          end

          def minimum_files
            @minimum_files ||= info.dig(:errors, :files, 0, :count) || 0
          end

          def submitted_files
            @submitted_files ||= form.files.count
          end
        end
      end
    end
  end
end
