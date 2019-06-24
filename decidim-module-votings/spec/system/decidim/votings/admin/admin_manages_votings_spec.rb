# frozen_string_literal: true

require "spec_helper"

describe "Admin manages votings", type: :system, serves_map: true do
  let(:manifest_name) { "votings" }
  let!(:voting) { create :voting, :n_votes, component: current_component }

  include_context "when managing a component as an admin"

  context "when creating a new voting" do
    before do
      click_link "New"
    end

    it "allows adding electoral district information" do
      fill_in_voting_form(
        "en" => "My voting",
        "es" => "Mi votación",
        "ca" => "La meua votació"
      )

      click_link "Add electoral district information"
      scope_pick select_data_picker(:"electoral-district-fields-id-decidim-scope-id"), scope
      fill_in "Voting identifier", with: "981"

      click_button "Create"
      expect(page).to have_content("Voting created successfully")

      within page.find("tr", text: "My voting") do
        page.find(".icon--pencil").click
      end

      within page.find(".electoral_districts", text: "Electoral districts") do
        expect(page).to have_content(scope.name["en"])
        expect(page).to have_field("Voting identifier", with: "981")
      end
    end

    context "with invalid data" do
      before do
        page.execute_script("$('#voting_start_date').focus()")
        page.find(".datepicker-dropdown .day", text: "12").click
        page.find(".datepicker-dropdown .hour", text: "10:00").click
        page.find(".datepicker-dropdown .minute", text: "10:50").click

        page.execute_script("$('#voting_end_date').focus()")
        page.find(".datepicker-dropdown .day", text: "12").click
        page.find(".datepicker-dropdown .hour", text: "12:00").click
        page.find(".datepicker-dropdown .minute", text: "12:50").click

        within ".new_voting" do
          fill_in :voting_voting_domain_name, with: "example.com"
          fill_in :voting_importance, with: "7"
          fill_in :voting_simulation_code, with: "5"

          find("*[type=submit]").click
        end
      end

      it "shows errors and redirects back to form" do
        within ".callout-wrapper" do
          expect(page).to have_content("Check the form data and correct the errors")
        end

        expect(page).to have_content("NEW VOTING")
      end
    end

    context "with valid data" do
      before do
        fill_in_voting_form(
          "en" => "My voting",
          "es" => "Mi votación",
          "ca" => "La meua votació"
        )

        within ".new_voting" do
          find("*[type=submit]").click
        end
      end

      it "shows a success message and redirects to voting list" do
        within ".callout-wrapper" do
          expect(page).to have_content("successfully")
        end

        within "table" do
          expect(page).to have_content("My voting")
        end
      end
    end
  end

  context "when updating a voting" do
    before do
      within find("tr", text: translated(voting.title)) do
        page.find("a.action-icon--edit").click
      end
    end

    it "allows changing electoral district information" do
      child_scope = create(:scope, parent: scope, name: { "en" => "Burkina", "es" => "Burkona", "ca" => "Burkana" })
      electoral_district = voting.electoral_districts.create!(scope: scope, voting_identifier: "666")

      refresh

      fill_in_voting_form(
        "en" => "My voting",
        "es" => "Mi votación",
        "ca" => "La meua votació"
      )

      scope_repick select_data_picker(:"electoral-district-fields-#{electoral_district.id}-decidim-scope-id"), scope, child_scope
      fill_in "Voting identifier", with: "981"

      click_button "Update"
      expect(page).to have_content("Voting updated successfully")

      within page.find("tr", text: "My voting") do
        page.find(".icon--pencil").click
      end

      within page.find(".electoral_districts", text: "Electoral districts") do
        expect(page).to have_content("Burkina")
        expect(page).to have_field("Voting identifier", with: "981")
      end
    end

    it "allows deleting electoral district information" do
      voting.electoral_districts.create!(scope: scope, voting_identifier: "666")
      refresh

      fill_in_voting_form(
        "en" => "My voting",
        "es" => "Mi votación",
        "ca" => "La meua votació"
      )

      page.find(".icon--circle-x").click

      click_button "Update"
      expect(page).to have_content("Voting updated successfully")

      within page.find("tr", text: "My voting") do
        page.find(".icon--pencil").click
      end

      within page.find(".electoral_districts", text: "Electoral districts") do
        expect(page).not_to have_content(scope.name["en"])
        expect(page).not_to have_field("Voting identifier", with: "666")
      end
    end

    context "with invalid data" do
      before do
        within ".edit_voting" do
          fill_in :voting_importance, with: "nonumber"
          fill_in :voting_simulation_code, with: "5"
          find("*[type=submit]").click
        end
      end

      it "shows errors and redirects back to form" do
        within ".callout-wrapper" do
          expect(page).to have_content("Check the form data and correct the errors")
        end

        expect(page).to have_content("EDIT VOTING")
      end
    end

    context "with valid data" do
      before do
        fill_in_voting_form(
          "en" => "My updated voting",
          "es" => "Mi votación actualizada",
          "ca" => "La meua votació actualitzada"
        )

        within ".edit_voting" do
          find("*[type=submit]").click
        end
      end

      it "shows a sucess message and redirects to voting list" do
        within ".callout-wrapper" do
          expect(page).to have_content("successfully")
        end

        within "table" do
          expect(page).to have_content("My updated voting")
        end
      end
    end
  end

  context "when deleting a voting" do
    let!(:voting2) { create(:voting, :not_started, component: current_component) }

    before do
      visit current_path
    end

    it "deletes a voting" do
      within find("tr", text: translated(voting2.title)) do
        accept_confirm { page.find("a.action-icon--remove").click }
      end

      within ".callout-wrapper" do
        expect(page).to have_content("successfully")
      end

      within "table" do
        expect(page).to have_no_content(translated(voting2.title))
      end
    end

    context "when the voting has started" do
      let!(:voting2) { create(:voting, component: current_component) }

      it "can't delete the voting" do
        within find("tr", text: translated(voting2.title)) do
          expect(page).to have_no_content("tr a.action-icon--remove")
        end
      end
    end
  end

  context "when previewing votings" do
    it "allows the user to preview the voting" do
      preview_window = nil
      within find("tr", text: translated(voting.title)) do
        preview_window = window_opened_by { find("a.action-icon--preview").click }
      end

      within_window preview_window do
        expect(page).to have_current_path(resource_locator(voting).path)
        expect(page).to have_content(translated(voting.title))
      end
    end

    context "when voting doesn't started yet" do
      let!(:voting) { create :voting, :n_votes, :not_started, component: current_component }

      it "allows the user to preview the voting" do
        new_window = nil
        within find("tr", text: translated(voting.title)) do
          new_window = window_opened_by { find("a.action-icon--preview").click }
        end

        within_window new_window do
          expect(page).to have_current_path(resource_locator(voting).path)
          expect(page).to have_content(translated(voting.title))
          expect(page).to have_content("UPCOMING")
        end
      end

      it "allows the user to simulate a vote" do
        new_window = nil
        within find("tr", text: translated(voting.title)) do
          new_window = window_opened_by { find("a.action-icon--simulate_vote").click }
        end

        within_window new_window do
          expect(page).to have_current_path(resource_locator(voting).path(key: voting.simulation_key))
          expect(page).to have_content(translated(voting.title))
          expect(page).to have_content("SIMULATE VOTE")
        end
      end
    end
  end

  private

  def fill_in_voting_form(title)
    fill_in_i18n(
      :voting_title,
      "#voting-title-tabs",
      en: title["en"],
      es: title["es"],
      ca: title["ca"]
    )

    fill_in_i18n_editor(
      :voting_description,
      "#voting-description-tabs",
      en: "My voting description",
      es: "La descripción de la votación",
      ca: "La descripció de la votació"
    )

    fill_in :voting_importance, with: "1"
    fill_in :voting_simulation_code, with: "5"

    page.execute_script("$('#voting_start_date').focus()")
    page.find(".datepicker-dropdown .day", text: "12").click
    page.find(".datepicker-dropdown .hour", text: "10:00").click
    page.find(".datepicker-dropdown .minute", text: "10:50").click

    page.execute_script("$('#voting_end_date').focus()")
    page.find(".datepicker-dropdown .day", text: "12").click
    page.find(".datepicker-dropdown .hour", text: "12:00").click
    page.find(".datepicker-dropdown .minute", text: "12:50").click
  end
end
