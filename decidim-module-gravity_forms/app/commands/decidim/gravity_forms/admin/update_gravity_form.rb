# frozen_string_literal: true

module Decidim
  module GravityForms
    module Admin
      # This command is executed when the user changes a Gravity Form from the
      # admin panel.
      class UpdateGravityForm < Rectify::Command
        # Initializes an UpdateGravityForm Command.
        #
        # form - The form from which to get the data.
        # gravity form - The current instance of the gravity form to be updated.
        def initialize(form, gravity_form)
          @form = form
          @gravity_form = gravity_form
        end

        # Updates the gravity form if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          update_gravity_form

          broadcast(:ok)
        end

        private

        attr_reader :gravity_form, :form

        def update_gravity_form
          gravity_form.update!(
            title: form.title,
            description: form.description,
            slug: form.slug,
            form_number: form.form_number,
            require_login: form.require_login,
            hidden: form.hidden,
            component: form.current_component
          )
        end
      end
    end
  end
end
