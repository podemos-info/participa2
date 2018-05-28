# frozen_string_literal: true

module Decidim
  module GravityForms
    class GravityFormsController < Decidim::GravityForms::ApplicationController
      helper_method :gravity_form, :visible_gravity_forms, :accessible_form?

      before_action :authenticate_user!, only: :show, if: -> { gravity_form.require_login }

      def index
        if visible_gravity_forms.one?
          redirect_to visible_gravity_forms.first if accessible_form?(visible_gravity_forms.first)
        end
      end

      private

      def visible_gravity_forms
        @visible_gravity_forms ||= gravity_forms.where(hidden: false)
      end

      def gravity_forms
        @gravity_forms ||= GravityForm.where(component: current_component)
      end

      def gravity_form
        @gravity_form ||= gravity_forms.find(params[:id])
      end

      def accessible_form?(gravity_form)
        !gravity_form.require_login ||
          gravity_form.require_login && user_signed_in?
      end
    end
  end
end
