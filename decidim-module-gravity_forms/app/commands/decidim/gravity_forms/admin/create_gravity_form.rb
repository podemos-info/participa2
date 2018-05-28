# frozen_string_literal: true

module Decidim
  module GravityForms
    module Admin
      # This command is executed when the user creates a Gravity form from the
      # admin panel.
      class CreateGravityForm < Rectify::Command
        def initialize(form)
          @form = form
        end

        # Creates the gravity form if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          create_gravity_form

          broadcast(:ok)
        end

        private

        attr_reader :form

        def create_gravity_form
          GravityForm.create!(
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
