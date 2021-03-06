# frozen_string_literal: true

require "spec_helper"

describe "Explore votings", type: :system do
  include_context "with a component"

  let(:manifest_name) { "votings" }

  describe "index page" do
    let(:votings_count) { 5 }

    context "when all votings are active" do
      let!(:votings) do
        create_list(:voting, votings_count, :n_votes, component: component)
      end

      it "shows all votings" do
        visit_component
        expect(page).to have_selector("article.card", count: votings_count)

        votings.each do |voting|
          expect(page).to have_content(translated(voting.title))
        end
      end
    end

    context "when there are no votings" do
      let!(:votings) { [] }

      it "shows a message" do
        visit_component
        expect(page).not_to have_selector("article.card")
        expect(page).to have_content("There is no active voting")
      end
    end

    context "when there are votings but all not active" do
      let!(:votings) { create_list(:voting, votings_count, :n_votes, :not_started, component: component) }

      it "shows a message" do
        visit_component
        expect(page).not_to have_selector("article.card")
        expect(page).to have_content("There is no active voting")
      end
    end
  end

  describe "show page" do
    let!(:user) { create :user, :confirmed, organization: organization }
    let!(:voting) { create(:voting, :n_votes, component: component, voting_identifier: "MAIN") }

    before do
      login_as user, scope: :user
    end

    it "has button for voting" do
      visit_component
      click_link translated(voting.title)
      expect(page).to have_link("Vote")
    end

    it "has a message about voting system used" do
      visit_component
      click_link translated(voting.title)
      expect(page).to have_content("Agora")
    end

    context "when the user has already voted" do
      let!(:vote) { create :vote, :confirmed, voting: voting, user: user }

      before do
        visit_component
      end

      it "shows a message informing" do
        click_link translated(voting.title)
        expect(page).to have_content("participated on this voting")
      end
    end

    context "when the user has not yet voted" do
      let(:scope) { create(:scope, organization: organization) }

      let!(:electoral_district) do
        create(
          :electoral_district,
          voting: voting,
          scope: scope,
          voting_identifier: "SECONDARY"
        )
      end

      context "with the default scope resolution (no scope)" do
        before do
          visit_component
          click_link translated(voting.title)
        end

        it "directs to the main booth" do
          click_link "Vote"

          expect(page).to have_link(href: %r{booth/MAIN/vote})
          expect(page).to have_content("Loading voting booth...")
        end
      end

      context "with a custom scope resolution" do
        around do |example|
          default_resolver = Decidim::Votings.scope_resolver
          Decidim::Votings.scope_resolver = ->(_user, _voting) { scope }

          example.run

          Decidim::Votings.scope_resolver = default_resolver
        end

        before do
          visit_component
          click_link translated(voting.title)
        end

        it "directs to the correct electoral district booth" do
          click_link "Vote"

          expect(page).to have_link(href: %r{booth/SECONDARY/vote})
          expect(page).to have_content("Loading voting booth...")
        end
      end
    end

    context "when the voting is upcoming" do
      let(:voting) { create(:voting, :n_votes, :upcoming, component: component, voting_identifier: "MAIN") }
      let(:voting_link) { resource_locator(voting).path }

      before do
        visit voting_link
      end

      it "does not allow to simulate vote" do
        expect(page).to have_content("UPCOMING")
        expect(page).not_to have_content("SIMULATE VOTE")
      end

      context "and the user has the simulation link" do
        let(:voting_link) { resource_locator(voting).path(key: voting.simulation_key) }

        it "allows to simulate vote" do
          click_link "Simulate vote"

          expect(page).to have_link(href: %r{booth/MAIN/vote})
          expect(page).to have_content("Loading voting booth...")
        end
      end
    end
  end
end
