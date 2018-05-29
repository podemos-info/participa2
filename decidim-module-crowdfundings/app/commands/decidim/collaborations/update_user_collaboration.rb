# frozen_string_literal: true

module Decidim
  module Collaborations
    # Rectify command that creates a user collaboration
    class UpdateUserCollaboration < Rectify::Command
      attr_reader :form

      def initialize(form)
        @form = form
      end

      # Updates the user collaboration if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid, form) if form.invalid?

        if form.context.user_collaboration.update(form.attributes)
          broadcast(:ok)
        else
          broadcast(:invalid)
        end
      end
    end
  end
end
