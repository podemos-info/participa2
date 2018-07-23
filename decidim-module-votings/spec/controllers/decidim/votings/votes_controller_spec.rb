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
          participatory_process_slug: component.participatory_space.slug,
          voting_id: voting.id,
          **extra_params
        }
      end

      let(:extra_params) { {} }
      let(:voting) { create(:voting, :n_votes, component: component) }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
        sign_in user
      end

      describe "show page" do
        subject { get :show, params: params }

        it "shows voting info" do
          is_expected.to have_http_status(:ok)
          is_expected.to render_template(layout: "layouts/decidim/booth")
        end

        context "when voting has not started yet" do
          let(:voting) { create(:voting, :n_votes, :not_started, component: component) }

          it "shows an error message" do
            is_expected.to have_http_status(:found)
            expect(flash[:error]).to eq("The voting doesn't started yet.")
          end

          context "with valid key" do
            let(:extra_params) { { key: voting.simulation_key } }

            it "shows voting info" do
              is_expected.to have_http_status(:ok)
              is_expected.to render_template(layout: "layouts/decidim/booth")
            end
          end
        end

        context "when voting has finished" do
          let(:voting) { create(:voting, :finished, component: component) }

          it "shows an error message" do
            is_expected.to have_http_status(:found)
            expect(flash[:error]).to eq("The voting has finished.")
          end
        end
      end

      describe "token request" do
        subject { post :token, params: params }

        let(:voter_id) { voting.votes.find_by(user: user).token }

        it "returns voter_id" do
          is_expected.to have_http_status(:ok)
          expect(response.body).to eq(voter_id)
        end

        context "when voting has not started yet" do
          let(:voting) { create(:voting, :n_votes, :not_started, component: component) }

          it "shows an error message" do
            is_expected.to have_http_status(:gone)
            expect(flash[:error]).to eq("The voting doesn't started yet.")
          end

          context "with valid key" do
            let(:extra_params) { { key: voting.simulation_key } }
            let(:voter_id) { voting.simulated_votes.find_by(user: user).token }

            it "returns voter_id" do
              is_expected.to have_http_status(:ok)
              expect(response.body).to eq(voter_id)
            end
          end
        end

        context "when voting has finished" do
          let(:voting) { create(:voting, :n_votes, :finished, component: component) }

          it "shows an error message" do
            is_expected.to have_http_status(:gone)
            expect(flash[:error]).to eq("The voting has finished.")
          end
        end
      end
    end
  end
end
