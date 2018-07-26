# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    describe EmitVote do
      subject { described_class.call(user: user, voting: voting, voting_identifier: voting_identifier) }

      let(:organization) { create(:organization) }
      let(:participatory_process) { create :participatory_process, organization: organization }
      let(:current_component) { create :voting_component, participatory_space: participatory_process }

      let(:context) do
        {
          current_organization: organization,
          current_component: current_component
        }
      end

      let(:user) { create(:user) }
      let(:voting) { create(:voting, :n_votes) }
      let(:voting_identifier) { voting.voting_identifier }

      it "broadcasts :ok" do
        expect { subject } .to broadcast(:ok)
      end

      it "creates the pending vote" do
        expect { subject } .to change(Vote.pending, :count).by(1)
      end

      it "doesn't create a simulated vote" do
        expect { subject } .not_to change(SimulatedVote, :count)
      end

      context "when a vote exists" do
        let!(:vote) { create(:vote, user: user, voting: voting) }

        it "broadcasts :ok" do
          expect { subject } .to broadcast(:ok)
        end

        it "doesn't create another vote" do
          expect { subject } .not_to change(Vote, :count)
        end

        it "updates vote updated_at" do
          expect { subject } .to change { vote.reload.updated_at }
        end

        it "doesn't update vote created_at" do
          expect { subject } .not_to change { vote.reload.created_at }
        end

        context "when vote was confirmed" do
          let!(:vote) { create(:vote, user: user, voting: voting, status: :confirmed) }

          it "sets vote status" do
            expect { subject } .to change { vote.reload.status } .from("confirmed").to("pending")
          end
        end
      end

      context "when a simulated vote exists" do
        let!(:vote) { create(:simulated_vote, user: user, voting: voting) }

        it "broadcasts :ok" do
          expect { subject } .to broadcast(:ok)
        end

        it "creates a new vote" do
          expect { subject } .to change(Vote, :count).by(1)
        end
      end

      context "when voting isn't started yet" do
        let(:voting) { create(:voting, :n_votes, :not_started) }

        it "broadcasts :ok" do
          expect { subject } .to broadcast(:ok)
        end

        it "creates a simulated vote" do
          expect { subject } .to change(SimulatedVote, :count).by(1)
        end

        it "doesn't create a real vote" do
          expect { subject } .not_to change(Vote, :count)
        end

        context "when a simulated vote exists" do
          let!(:vote) { create(:simulated_vote, user: user, voting: voting) }

          it "broadcasts :ok" do
            expect { subject } .to broadcast(:ok)
          end

          it "doesn't create another vote" do
            expect { subject } .not_to change(Vote, :count)
          end

          it "updates vote updated_at" do
            expect { subject } .to change { vote.reload.updated_at }
          end

          it "doesn't update vote created_at" do
            expect { subject } .not_to change { vote.reload.created_at }
          end

          context "with a different simulation_code" do
            let!(:vote) { create(:simulated_vote, user: user, voting: voting, simulation_code: 111) }

            it "broadcasts :ok" do
              expect { subject } .to broadcast(:ok)
            end

            it "creates another simulated vote" do
              expect { subject } .to change(SimulatedVote, :count).by(1)
            end
          end
        end
      end

      context "when arguments are invalid" do
        let(:voting_identifier) { nil }

        it "broadcasts :invalid" do
          expect { subject } .to broadcast(:invalid)
        end

        it "doesn't create a real vote" do
          expect { subject } .not_to change(Vote, :count)
        end

        it "doesn't create a simulated vote" do
          expect { subject } .not_to change(SimulatedVote, :count)
        end
      end
    end
  end
end
