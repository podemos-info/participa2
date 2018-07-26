# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::SimulatedVote do
  let(:vote) { create(:simulated_vote, user: user, voting: voting, simulation_code: simulation_code) }
  let(:user) { create(:user, id: 1) }
  let(:voting) { create(:voting, :n_votes, :not_started, id: 1) }
  let(:simulation_code) { voting.simulation_code }

  describe "token" do
    subject { vote.token }

    before { allow(Rails.application.secrets).to receive(:secret_key_base).and_return("a_secret_key_base") }

    around do |example|
      Timecop.freeze(Date.new(2014, 5, 25)) { example.run }
    end

    it "returns a valid token" do
      is_expected.to eq("5916b4d1755bb6be1a6453872833fc57a06461155653dc0639562ab8c48f9287/5b8e71f52172534d48a53fe7c0d02a4061656b807870b581a444f9a194f86cf8:AuthEvent:666:vote:1400976000")
    end

    context "when creating another vote for the same user and voting" do
      let!(:vote2) { create(:simulated_vote, user: user, voting: voting) }

      it "raises an error" do
        expect { subject } .to raise_error(ActiveRecord::RecordNotUnique)
      end

      context "when simulation code changes" do
        let(:simulation_code) { 1 }

        it "returns a valid and different token" do
          is_expected.to eq("eebfe1e6b324df5df2b842d12a8dbd662eff3d773a1dcd7dfd619a0a50b80d59/7c4d6a17302afd0dccf8040ad223a5c12b22cb7416df8cf19bc45d2c59fb26f6:AuthEvent:666:vote:1400976000")
        end
      end
    end

    context "when vote is not saved yet" do
      let(:vote) { build(:simulated_vote, user: user, voting: voting) }

      it "returns an error" do
        expect { subject } .to raise_error("Vote should be saved before used")
      end
    end
  end
end
