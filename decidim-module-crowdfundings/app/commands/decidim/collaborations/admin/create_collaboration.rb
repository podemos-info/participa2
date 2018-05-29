# frozen_string_literal: true

module Decidim
  module Collaborations
    module Admin
      # This command is executed when the user creates a Collaboration from
      # the admin panel.
      class CreateCollaboration < CollaborationCommand
        # Creates the collaboration if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?
          create_collaboration
          broadcast(:ok)
        end

        private

        def create_collaboration
          Collaboration.create(
            component: form.current_component,
            title: form.title,
            description: form.description,
            terms_and_conditions: form.terms_and_conditions,
            default_amount: form.default_amount,
            minimum_custom_amount: form.minimum_custom_amount,
            target_amount: form.target_amount,
            active_until: form.active_until,
            amounts: amounts
          )
        end
      end
    end
  end
end
