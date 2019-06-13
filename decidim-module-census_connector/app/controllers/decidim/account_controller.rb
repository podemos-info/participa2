# frozen_string_literal: true

# This override makes AccountController to include the person_proxy in the forms context

require File.expand_path("../../../app/controllers/decidim/account_controller", Decidim::Core::Engine.called_from)

module Decidim
  AccountController.class_eval do
    alias_method :old_form, :form

    def form(klass)
      Class.new(old_form(klass).class) do
        def context
          super.merge(person_proxy: @controller.try(:person_proxy))
        end
      end.new(klass, self)
    end
  end
end
