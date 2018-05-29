# frozen_string_literal: true

module Decidim
  module GravityForms
    module Admin
      # Administration of Gravity Forms
      class GravityFormsController < Admin::ApplicationController
        helper_method :gravity_forms

        def new
          @form = form(GravityFormForm).instance
        end

        def create
          @form = form(GravityFormForm).from_params(params, current_component: current_component)

          CreateGravityForm.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("gravity_forms.create.success", scope: "decidim.gravity_forms.admin")
              redirect_to gravity_forms_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("gravity_forms.create.invalid", scope: "decidim.gravity_forms.admin")
              render action: "new"
            end
          end
        end

        def edit
          authorize! :edit, gravity_form

          @form = form(GravityFormForm).from_model(gravity_form)
        end

        def update
          authorize! :edit, gravity_form

          @form = form(GravityFormForm).from_params(params, current_component: current_component)

          UpdateGravityForm.call(@form, gravity_form) do
            on(:ok) do
              flash[:notice] = I18n.t("gravity_forms.update.success", scope: "decidim.gravity_forms.admin")
              redirect_to gravity_forms_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("gravity_forms.update.invalid", scope: "decidim.gravity_forms.admin")
              render action: "edit"
            end
          end
        end

        private

        def gravity_forms
          @gravity_forms ||= GravityForm.where(component: current_component)
        end

        def gravity_form
          @gravity_form ||= gravity_forms.find(params[:id])
        end
      end
    end
  end
end
