# frozen_string_literal: true

module Decidim
  module Collaborations
    module Admin
      # This command is executed when the user changes a Collaboration from
      # the admin panel.
      class UpdateCollaboration < CollaborationCommand
        # Initializes an UpdateProject Command.
        #
        # form - The form from which to get the data.
        # collaboration - The current instance of the collaboration to be updated.
        def initialize(form, collaboration)
          super(form)
          @collaboration = collaboration
        end

        # Updates the collaboration if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          update_collaboration
          broadcast(:ok)
        end

        private

        attr_reader :collaboration

        def update_collaboration
          collaboration.update!(
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
