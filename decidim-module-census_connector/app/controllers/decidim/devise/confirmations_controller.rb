# frozen_string_literal: true

# This override makes ConfirmationsController to create a data change procedure on census

require File.expand_path("../../../app/controllers/decidim/devise/confirmations_controller", Decidim::Core::Engine.called_from)

module Decidim::Devise
  ConfirmationsController.class_eval do
    include Decidim::CensusConnector::CensusContext

    alias_method :old_show, :show

    def show
      return old_show unless has_person?

      ret = nil
      Decidim::User.transaction do
        ret = old_show do |resource|
          result, _info = person_proxy.update(email: resource.email)
          unless result == :ok
            resource.errors.add :email, :census_down
            raise ActiveRecord::Rollback
          end
        end
      end

      return ret if ret

      redirect_to root_path, alert: I18n.t("errors.messages.census_down")
    end
  end
end
