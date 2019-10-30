# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/factories"

module Decidim::CensusConnector
  describe "Destroy account", :vcr, type: :system do
    before do
      local_scope
      create_person_scopes(organization, person)
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim.delete_account_path
    end

    let(:organization) { create(:organization) }
    let(:local_scope) { create(:scope, code: Decidim::CensusConnector.census_local_code, organization: organization) }

    let(:user) { create(:user, :confirmed, :with_person, organization: organization, person_id: 9) }
    let(:person) { person_proxy.person }
    let(:person_proxy) { PersonProxy.for(user) }

    it "the user can delete his account" do
      fill_in :delete_account_delete_reason, with: "I just want to delete my account"

      click_button "Delete my account"

      click_button "Yes, I want to delete my account"

      within_flash_messages do
        expect(page).to have_content("successfully")
      end

      find(".sign-in-link").click

      login_as user, scope: :user

      expect(page).to have_no_content("Signed in successfully")
      expect(page).to have_no_content(user.name)
    end
  end
end
