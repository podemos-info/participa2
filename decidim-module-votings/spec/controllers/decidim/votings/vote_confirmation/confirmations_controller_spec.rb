# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module VoteConfirmation
      describe ConfirmationsController, type: :controller do
        routes { Decidim::Votings::VoteConfirmationEngine.routes }

        let(:vote) { create(:vote, voting: voting, user: user) }

        let(:user) { create(:user, :confirmed, organization: component.organization) }
        let(:component) { create :voting_component, :participatory_process }

        let(:voting_identifier) { voting.voting_identifier }
        let(:voter_identifier) { vote.voter_identifier }
        let(:voting) { create(:voting, component: component, voting_identifier: "6666") }

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "#index" do
          subject { get :confirm, params: { voting_identifier: voting_identifier, voter_identifier: voter_identifier } }

          context "when vote exists" do
            it "confirms the vote" do
              is_expected.to have_http_status(:ok)
              expect(JSON.parse(response.body)["result"]).to eq "ok"
              expect(vote.reload.status).to eq "confirmed"
            end

            context "when voting_identifier doesn't match" do
              let(:voting_identifier) { "1111" }

              it "doesn't confirm the vote" do
                is_expected.to have_http_status(:ok)
                expect(JSON.parse(response.body)["result"]).to eq "error"
                expect(vote.reload.status).not_to eq "confirmed"
              end
            end

            context "when voter_identifier doesn't match" do
              let(:voter_identifier) { "jajaja" }

              it "doesn't confirm the vote" do
                is_expected.to have_http_status(:ok)
                expect(JSON.parse(response.body)["result"]).to eq "error"
                expect(vote.reload.status).not_to eq "confirmed"
              end
            end
          end

          context "when simulated vote exists" do
            let(:vote) { create(:simulated_vote, voting: voting, user: user) }

            it "confirms the vote" do
              is_expected.to have_http_status(:ok)
              expect(JSON.parse(response.body)["result"]).to eq "ok"
              expect(vote.reload.status).to eq "confirmed"
            end
          end

          context "when both votes exists" do
            let(:simulated_vote) { create(:simulated_vote, voting: voting, user: user) }

            it "confirms the vote" do
              is_expected.to have_http_status(:ok)
              expect(JSON.parse(response.body)["result"]).to eq "ok"
              expect(vote.reload.status).to eq "confirmed"
              expect(simulated_vote.reload.status).not_to eq "confirmed"
            end
          end
        end
      end
    end
  end
end
