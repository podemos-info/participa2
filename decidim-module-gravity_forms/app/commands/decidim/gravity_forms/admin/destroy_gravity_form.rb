# frozen_string_literal: true

module Decidim
  module GravityForms
    module Admin
      # This command is executed when the user destroys a GravityForm from the admin
      # panel.
      class DestroyGravityForm < Rectify::Command
        # Initializes a DestroyGravityForm Command.
        #
        # gravity_form - The instance of the gravity form to destroy.
        def initialize(gravity_form)
          @gravity_form = gravity_form
        end

        # Destroys the gravity form if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          destroy_gravity_form

          broadcast(:ok)
        end

        private

        attr_reader :gravity_form

        def destroy_gravity_form
          gravity_form.destroy!
        end
      end
    end
  end
end
