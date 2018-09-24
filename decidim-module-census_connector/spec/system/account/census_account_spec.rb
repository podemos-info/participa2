# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/factories"

module Decidim::CensusConnector
  describe "Census account", type: :system do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, :with_incomplete_person, organization: organization) }
    let(:person) { person_proxy.person }
    let(:person_proxy) { PersonProxy.for(user) }
    let(:cassette) { "existing_person" }

    around do |example|
      VCR.use_cassette(cassette, {}, &example)
    end

    before do
      create_person_scopes(organization, person)
      switch_to_host(organization.host)
      login_as user, scope: :user
      visit decidim_census_account.root_path
    end

    it "shows the personal data information" do
      expect(page).to have_content("PERSONAL DATA")
      expect(page).to have_content(person.first_name)
      expect(page).to have_content(person.last_name1)
      expect(page).to have_content(person.last_name2)
      expect(page).to have_content(person.document_id)
    end

    it "shows the location data information" do
      expect(page).to have_content("LOCATION")
      expect(page).to have_content(translated(person.address))
      expect(page).to have_content(translated(person.scope.name))
    end

    it "shows the person phone" do
      expect(page).to have_content("MOBILE PHONE")
      expect(page).to have_content(translated(person.phone))
    end

    it "allows to modify personal data" do
      within ".card--list__item.data_card" do
        click_link("Modify")
      end
      expect(page).to have_content("Personal data")
    end

    it "allows to modify location data" do
      within ".card--list__item.scope_card" do
        click_link("Modify")
      end
      expect(page).to have_content("Location")
    end

    it "allows to modify phone data" do
      within ".card--list__item.phone_card" do
        click_link("Modify")
      end
      expect(page).to have_content("Mobile phone")
    end
  end
end
