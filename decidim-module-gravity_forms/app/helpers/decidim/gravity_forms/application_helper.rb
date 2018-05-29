# frozen_string_literal: true

module Decidim
  module GravityForms
    # Custom helpers, scoped to the gravity_forms engine.
    #
    module ApplicationHelper
      # Public: Emulates a `link_to` to a gravity form but conditionally renders
      # a login popup modal if the form requires authenticated and the user is
      # not authenticated.
      #
      # title - The title of the link
      # gravity_form - The gravity form the needs to be checked.
      # html_options - A regular set of arguments that would be provided to
      # `link_to`.
      #
      # Returns a String with the link.
      def authenticated_link_to(title, gravity_form, html_options = {})
        unless accessible_form?(gravity_form)
          html_options["onclick"] = "event.preventDefault();"
          html_options["data-open"] = "loginModal"
        end

        link_to(title, gravity_form, html_options)
      end
    end
  end
end
