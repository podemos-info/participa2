# frozen_string_literal: true

module Decidim
  module GravityForms
    class GravityFormsController < Decidim::GravityForms::ApplicationController
      helper_method :gravity_form, :visible_gravity_forms, :can_fill_in_form?

      before_action :authenticate_user!, only: :show, if: -> { gravity_form.require_login }

      def index
        redirect_to(gravity_form) if visible_gravity_forms.one? && can_fill_in_form?
      end

      def show; end

      private

      def visible_gravity_forms
        @visible_gravity_forms ||= gravity_forms.where(hidden: false)
      end

      def gravity_forms
        @gravity_forms ||= GravityForm.where(component: current_component)
      end

      def gravity_form
        @gravity_form ||= if params[:slug]
                            gravity_forms.find_by(slug: params[:slug])
                          else
                            visible_gravity_forms.first
                          end
      end

      def can_fill_in_form?
        @can_fill_in_form ||= (!gravity_form.require_login || user_signed_in?) && allowed_to?(:fill_in, :gravity_form, gravity_form: gravity_form)
      end
    end
  end
end
