# frozen_string_literal: true

require "spec_helper"

module Decidim
  module GravityForms
    describe GravityFormsController, type: :controller do
      routes { Decidim::GravityForms::Engine.routes }

      let(:user) { create(:user, :confirmed, organization: component.organization) }

      let(:params) do
        {
          id: gravity_form.id,
          component_id: component.id
        }
      end

      let(:component) { gravity_form.component }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
      end

      shared_examples_for "a successful page visit" do
        it "successfully renders the form" do
          get :show, params: params

          expect(response).to have_http_status(:ok)
          expect(response).to render_template(:show)
        end
      end

      shared_examples_for "an unauthenticated page visit" do
        it "redirects to login page" do
          get :show, params: params

          expect(response).to have_http_status(:redirect)
          expect(response).to redirect_to("/users/sign_in")
        end
      end

      describe "GET show" do
        let(:gravity_form) do
          create(:gravity_form, require_login: require_login)
        end

        context "when user logged in" do
          before { sign_in user }

          context "and the form requires login" do
            let(:require_login) { true }

            it_behaves_like "a successful page visit"
          end

          context "and the form does not require login" do
            let(:require_login) { false }

            it_behaves_like "a successful page visit"
          end
        end

        context "when user not logged in" do
          context "and the form requires login" do
            let(:require_login) { true }

            it_behaves_like "an unauthenticated page visit"
          end

          context "and the form does not require login" do
            let(:require_login) { false }

            it_behaves_like "a successful page visit"
          end
        end
      end
    end
  end
end
