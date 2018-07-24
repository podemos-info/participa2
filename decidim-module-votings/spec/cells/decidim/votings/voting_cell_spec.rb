# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::VotingCell, type: :cell do
  controller Decidim::Votings::VotingsController

  subject { my_cell.call }

  let(:my_cell) { cell("decidim/votings/voting", voting) }
  let(:voting) { create(:voting, :n_votes) }
  let!(:current_user) { create(:user, :confirmed, organization: voting.participatory_space.organization) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  context "when rendering a voting" do
    it "renders the card" do
      is_expected.to have_css(".card--voting")
    end

    it "allows to vote" do
      within ".card__footer .card__support .card__button" do
        is_expected.to have_content("Vote")
      end
    end

    context "when voting has not started yet" do
      let(:voting) { create(:voting, :n_votes, :not_started) }

      it "doesn't allows to vote" do
        within ".card__footer .card__support .card__button" do
          is_expected.not_to have_content("Vote")
          is_expected.to have_content("Upcoming")
        end
      end
    end
  end
end
