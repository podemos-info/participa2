# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::Vote do
  let(:vote) { create(:vote, user: user, voting: voting) }
  let(:user) { create(:user, id: 1) }
  let(:voting) { create(:voting, :n_votes, id: 1) }

  describe "token" do
    subject { vote.token }

    before { allow(Rails.application.secrets).to receive(:secret_key_base).and_return("a_secret_key_base") }

    around do |example|
      Timecop.freeze(Date.new(2014, 5, 25)) { example.run }
    end

    it "returns a valid token" do
      is_expected.to eq("3c1bf299abc842a77b34299d5407a6f7637915b22a44a9da39127fc967a6c911/2f48478e987d958fbd09dfbe9c4196db4f91cd5606d51f794cc7128f7015346f:AuthEvent:666:vote:1400976000")
    end

    context "when creating another vote for the same user and voting" do
      let!(:vote2) { create(:vote, user: user, voting: voting) }

      it "raises an error" do
        expect { subject } .to raise_error(ActiveRecord::RecordNotUnique)
      end
    end

    context "when vote is not saved yet" do
      let(:vote) { build(:vote, user: user, voting: voting) }

      it "returns an error" do
        expect { subject } .to raise_error("Vote should be saved before used")
      end
    end
  end
end
