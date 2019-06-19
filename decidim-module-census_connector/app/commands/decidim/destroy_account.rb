# frozen_string_literal: true

# This override makes DestroyAccount command to create a cancellation procedure on census

require File.expand_path("../../../app/commands/decidim/destroy_account", Decidim::Core::Engine.called_from)

module Decidim
  DestroyAccount.class_eval do
    alias_method :old_destroy_user_group_memberships, :destroy_user_group_memberships

    private

    def destroy_user_group_memberships
      old_destroy_user_group_memberships

      person_proxy.create_cancellation(cancellation_params)
    end

    def cancellation_params
      {
        reason: @form.delete_reason,
        channel: :decidim
      }
    end

    def person_proxy
      @form.context.person_proxy
    end
  end
end
