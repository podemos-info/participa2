# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    describe VotesController, type: :controller do
      routes { Decidim::Votings::Engine.routes }

      let(:user) { create(:user, :confirmed, organization: component.organization) }

      let(:component) { create :voting_component, :participatory_process }

      let(:params) do
        {
          component_id: component.id,
          participatory_process_slug: component.participatory_space.slug
        }
      end

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
        sign_in user
      end

      context "when calling show" do
        context "when voting is started" do
          let!(:voting) { create(:voting, component: component) }

          context "with valid key" do
            it "shows voting info" do
              get :show, params: params.merge(voting_id: voting.id, key: voting.simulation_key)
              expect(response).to have_http_status(:ok)
              expect(response).to render_template(layout: "layouts/decidim/booth")
            end
          end
          context "with invalid key" do
            it "shows voting info" do
              get :show, params: params.merge(voting_id: voting.id, key: "fakekey")
              expect(response).to have_http_status(:ok)
              expect(response).to render_template(layout: "layouts/decidim/booth")
            end
          end
        end
        context "when voting is not started" do
          let!(:voting) { create(:voting, :not_started, component: component) }

          context "with valid key" do
            it "shows voting info" do
              get :show, params: params.merge(voting_id: voting.id, key: voting.simulation_key)
              expect(response).to have_http_status(:ok)
              expect(response).to render_template(layout: "layouts/decidim/booth")
            end
          end
          context "with invalid key" do
            it "shows voting info" do
              expect do
                get :show, params: params.merge(voting_id: voting.id, key: "fakekey")
              end.to raise_error(ActionController::RoutingError)
            end
          end
        end
      end
    end
  end
end
