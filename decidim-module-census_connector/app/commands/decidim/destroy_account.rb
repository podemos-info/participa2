# frozen_string_literal: true

# This override makes DestroyAccount command to create a cancellation procedure on census

require File.expand_path("../../../app/commands/decidim/destroy_account", Decidim::Core::Engine.called_from)

# UPDATABLE: Destroy person inside destroying account transaction
Decidim::DestroyAccount.class_eval do
  alias_method :old_destroy_follows, :destroy_follows

  private

  def destroy_follows
    old_destroy_follows

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
