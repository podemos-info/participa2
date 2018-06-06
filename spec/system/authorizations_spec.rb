# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Census authorization", type: :system do
  let(:organization) { create(:organization, available_authorizations: ["census"]) }
  let(:user) { create(:user, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "redirects the authorizations tab to the census account" do
    visit "/authorizations"

    expect(page).to have_current_path("/census_account")
  end

  it "hides the authorizations tab" do
    visit "/account"

    expect(page).to have_no_link("Autorizaciones")
  end
end
