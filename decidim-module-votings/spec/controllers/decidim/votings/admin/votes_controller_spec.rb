# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe VotesController, type: :controller do
        routes { Decidim::Votings::AdminEngine.routes }

        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

        let(:component) { create :voting_component, :participatory_process }

        let(:election_id) { "6666" }

        let(:vote_voter_id) { "6036dfb5fb227d22f8728317d572d972f67304c188281cd72319a581502a7ef2" }
        let(:simulated_voter_id) { "7036dfb5fb227d22f8728317d572d972f67304c188281cd72319a581502a7ef2" }
        let(:other_voter_id) { "8036dfb5fb227d22f8728317d572d972f67304c188281cd72319a581502a7ef2" }

        let(:params) do
          {
            component_id: component.id,
            participatory_process_slug: component.participatory_space.slug,
            voting_id: voting.id,
            format: "txt"
          }
        end

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_component"] = component
          sign_in user
        end

        context "when getting list of voters identifiers" do
          let!(:vote) { create(:vote, voting: voting, voter_identifier: vote_voter_id, user: user) }
          let!(:simulated_vote) { create(:simulated_vote, voting: voting, voter_identifier: simulated_voter_id, user: user, simulation_code: 666) }
          let!(:simulated_vote_other) { create(:simulated_vote, voting: voting, voter_identifier: other_voter_id, user: user, simulation_code: 777) }

          context "when voting is not started" do
            let(:voting) { create(:voting, :not_started, component: component, voting_identifier: election_id, simulation_code: 666) }

            it "shows only voter_id of simulated votes of the same simulation" do
              get :index, params: params
              identifiers = assigns(:votes).map(&:voter_identifier)
              expect(identifiers).to include simulated_vote.voter_identifier
              expect(identifiers).not_to include simulated_vote_other.voter_identifier
              expect(identifiers).not_to include vote.voter_identifier
            end
          end

          context "when voting has started" do
            let(:voting) { create(:voting, component: component, voting_identifier: election_id, simulation_code: 666) }

            it "shows only voter_id of votes without simulateds" do
              get :index, params: params
              identifiers = assigns(:votes).map(&:voter_identifier)
              expect(identifiers).not_to include simulated_vote.voter_identifier
              expect(identifiers).not_to include simulated_vote_other.voter_identifier
              expect(identifiers).to include vote.voter_identifier
            end
          end
        end
      end
    end
  end
end
