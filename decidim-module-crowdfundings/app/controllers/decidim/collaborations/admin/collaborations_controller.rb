# frozen_string_literal: true

module Decidim
  module Collaborations
    module Admin
      class CollaborationsController < Admin::ApplicationController
        before_action :init_form_from_params, only: [:create, :update]

        helper Decidim::Collaborations::TotalsHelper

        def new
          @form = collaboration_form.instance
          @form.amounts = Decidim::Collaborations.selectable_amounts.join(", ")
        end

        def create
          CreateCollaboration.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("collaborations.create.success", scope: "decidim.collaborations.admin")
              redirect_to collaborations_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("collaborations.create.invalid", scope: "decidim.collaborations.admin")
              render action: "new"
            end
          end
        end

        def edit
          @form = collaboration_form.from_model(collaboration)
        end

        def update
          UpdateCollaboration.call(@form, collaboration) do
            on(:ok) do
              flash[:notice] = I18n.t("collaborations.update.success", scope: "decidim.collaborations.admin")
              redirect_to collaborations_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("collaborations.update.invalid", scope: "decidim.collaborations.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          collaboration.destroy!
          flash[:notice] = I18n.t("collaborations.destroy.success", scope: "decidim.collaborations.admin")
          redirect_to collaborations_path
        end

        private

        def init_form_from_params
          @form = collaboration_form.from_params(params)
        end

        def collaboration_form
          form(CollaborationForm)
        end
      end
    end
  end
end
