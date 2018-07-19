# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    describe VotingsController, type: :controller do
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

      context "when calling index" do
        context "with one voting" do
          let!(:voting) { create(:voting, component: component) }
          let(:path) do
            EngineRouter
              .main_proxy(component)
              .voting_path(voting)
          end

          it "has an element" do
            get :index, params: params
            expect(assigns(:votings)).not_to be_empty
          end
        end

        context "with one voting not open" do
          let!(:voting) { create(:voting, :not_started, component: component) }
          let(:path) do
            EngineRouter
              .main_proxy(component)
              .voting_path(voting)
          end

          it "has no content" do
            get :index, params: params
            expect(assigns(:votings)).to be_empty
          end
        end

        context "with several votings" do
          let!(:votings) { create_list(:voting, 2, component: component) }

          it "redirects to the voting page" do
            get :index, params: params
            expect(assigns(:votings).count).to eq 2
          end
        end
      end

      context "when calling show" do
        context "when voting is started" do
          let!(:voting) { create(:voting, component: component) }

          context "with valid key" do
            it "shows voting info" do
              get :show, params: params.merge(id: voting.id, key: voting.simulation_key)
              expect(response).to have_http_status(:ok)
            end
          end

          context "with invalid key" do
            it "shows voting info" do
              get :show, params: params.merge(id: voting.id, key: "fakekey")
              expect(response).to have_http_status(:ok)
            end
          end
        end

        context "when voting is not started" do
          let!(:voting) { create(:voting, :not_started, component: component) }

          context "with valid key" do
            it "shows voting info" do
              get :show, params: params.merge(id: voting.id, key: voting.simulation_key)
              expect(response).to have_http_status(:ok)
            end
          end

          context "with invalid key" do
            it "shows voting info" do
              get :show, params: params.merge(id: voting.id, key: "fakekey")
              expect(response).to have_http_status(:ok)
            end
          end
        end
      end
    end
  end
end
