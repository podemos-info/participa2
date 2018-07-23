# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module VoteConfirmation
      describe ConfirmationsController, type: :controller do
        routes { Decidim::Votings::VoteConfirmationEngine.routes }

        let(:user) { create(:user, :confirmed, organization: component.organization) }

        let(:component) { create :voting_component, :participatory_process }

        let(:election_id) { "6666" }

        let(:voter_id) { "6036dfb5fb227d22f8728317d572d972f67304c188281cd72319a581502a7ef2" }

        let(:voting) { create(:voting, component: component, voting_identifier: election_id) }

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_component"] = component
          sign_in user
        end

        context "when confirming existing vote" do
          context "when vote exists" do
            let!(:vote) { create(:vote, voting: voting, voter_identifier: voter_id, user: user) }

            context "when election_id matches" do
              it "confirms the vote" do
                get :confirm, params: { election_id: election_id, voter_id: voter_id }
                expect(JSON.parse(response.body)["result"]).to eq "ok"
                expect(Decidim::Votings::Vote.last.status).to eq "confirmed"
              end
            end

            context "when election_id does'nt match" do
              it "does'nt confirm the vote" do
                get :confirm, params: { election_id: "1111", voter_id: voter_id }
                expect(JSON.parse(response.body)["result"]).to eq "ok"
                expect(Decidim::Votings::Vote.last.status).not_to eq "confirmed"
              end
            end
          end

          context "when vote does'nt exist" do
            it "returns ok" do
              get :confirm, params: { election_id: election_id, voter_id: voter_id }
              expect(JSON.parse(response.body)["result"]).to eq "ok"
            end
          end

          context "when simulated vote exists" do
            let!(:simulated_vote) { create(:simulated_vote, voting: voting, voter_identifier: voter_id, user: user) }

            it "confirms the vote" do
              get :confirm, params: { election_id: election_id, voter_id: voter_id }
              expect(JSON.parse(response.body)["result"]).to eq "ok"
              expect(Decidim::Votings::SimulatedVote.last.status).to eq "confirmed"
            end
          end
        end
      end
    end
  end
end
