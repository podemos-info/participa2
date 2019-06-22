# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Account
      # A command to delete social network information for a person.
      class DeleteSocialNetwork < Rectify::Command
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

          delete_social_network

          add_errors_to_form
          broadcast(result)
        end

        private

        attr_reader :form, :person_proxy, :result, :info

        def delete_social_network
          @result, @info = person_proxy.save_additional_information(social_network_params)
        end

        def add_errors_to_form
          ErrorConverter.new(form, info[:errors]).run if result == :invalid
        end

        def social_network_params
          {
            key: "social_network_#{network}",
            value: nil
          }
        end

        delegate :network, to: :form
      end
    end
  end
end
