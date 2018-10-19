# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/factories"
require "decidim/census_connector/test/person_scopes"

describe "Crowdfunding activism type", type: :system do
  around do |example|
    VCR.use_cassette(cassette, {}, &example)
  end

  before do
    local_scope
    create_person_scopes(organization, person)
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_census_account.root_path
  end

  let(:organization) { create(:organization) }
  let(:local_scope) { create(:scope, code: Decidim::CensusConnector.census_local_code, organization: organization) }

  let(:user) { create(:user, :confirmed, :with_person, organization: organization) }
  let(:person) { person_proxy.person }
  let(:person_proxy) { Decidim::CensusConnector::PersonProxy.for(user) }

  let(:cassette) { "crowdfunding_activism_type_inactive" }

  it "shows the crowdfunding activism type" do
    within ".card--list__item.activism_type_crowdfunding_card" do
      expect(page).to have_content("Economic contribution")
      expect(page).to have_content("INACTIVE")
    end
  end

  it "allows to modify activism status" do
    within ".card--list__item.activism_type_crowdfunding_card" do
      click_link("Edit")
    end
    expect(page).to have_content("Your recurrent contributions")
  end

  context "when the person has a contribution" do
    before { contribution }

    let(:cassette) { "crowdfunding_activism_type_active" }
    let(:contribution) { create(:contribution, :monthly, :accepted, user: user) }

    it "shows the activism status" do
      within ".card--list__item.activism_card" do
        expect(page).to have_content("ACTIVISM")
        expect(page).to have_content("ACTIVIST")
      end
    end

    it "shows the crowdfunding activism type" do
      within ".card--list__item.activism_type_crowdfunding_card" do
        expect(page).to have_content("Economic contribution")
        expect(page).to have_content("ACTIVE")
      end
    end

    it "allows to modify activism status" do
      within ".card--list__item.activism_type_crowdfunding_card" do
        click_link("Edit")
      end
      expect(page).to have_content("Your recurrent contributions")
    end
  end
end
