# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe VotesController, type: :controller do
        routes { Decidim::Votings::AdminEngine.routes }

        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

        let(:component) { create :voting_component, :participatory_process }

        let(:voting_identifier) { "6666" }

        let(:params) do
          {
            component_id: component.id,
            participatory_process_slug: component.participatory_space.slug,
            voting_id: voting.id,
            format: "tsv"
          }
        end

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "#index" do
          subject { get :index, params: params }

          let(:voting) { create(:voting, component: component, voting_identifier: voting_identifier, simulation_code: 666) }
          let!(:vote) { create(:vote, voting: voting, user: user) }
          let!(:simulated_vote) { create(:simulated_vote, voting: voting, user: user, simulation_code: 666) }
          let!(:simulated_vote_other) { create(:simulated_vote, voting: voting, user: user, simulation_code: 777) }

          it "shows only voter_id of real votes" do
            is_expected.to have_http_status(:ok)
            expect(response.body).not_to include simulated_vote.voter_identifier
            expect(response.body).not_to include simulated_vote_other.voter_identifier
            expect(response.body).to include vote.voter_identifier
          end

          context "when voting is not started" do
            let(:voting) { create(:voting, :not_started, component: component, voting_identifier: voting_identifier, simulation_code: 666) }

            it "shows only voter_id of simulated votes of the same simulation" do
              is_expected.to have_http_status(:ok)
              expect(response.body).to include simulated_vote.voter_identifier
              expect(response.body).not_to include simulated_vote_other.voter_identifier
              expect(response.body).not_to include vote.voter_identifier
            end
          end
        end
      end
    end
  end
end
