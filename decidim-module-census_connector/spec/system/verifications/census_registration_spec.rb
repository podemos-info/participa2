# frozen_string_literal: true

require "spec_helper"

require "decidim/core/test/factories"

describe "Census registration", type: :system do
  before do
    inner_scope && exterior_scope && other_organization_scope
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_census_account.root_path
    click_link "Registration in Podemos"
    click_link "Sign up to take part in votings"
  end

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }

  let(:inner_scope) { create(:scope, code: Decidim::CensusConnector.census_local_code, organization: organization) }
  let(:exterior_scope) { create(:scope, code: Decidim::CensusConnector.census_non_local_code, organization: organization) }
  let(:other_organization_scope) { create(:scope, parent: exterior_scope) }

  it "asks for participation place only for exterior participants" do
    expect(page).to have_no_content("Participation place")

    scope_pick select_data_picker(:data_address_scope_id), exterior_scope
    expect(page).to have_content("Participation place")

    scope_repick select_data_picker(:data_address_scope_id), exterior_scope, inner_scope
    expect(page).to have_no_content("Participation place")
  end

  it "shows only organization scopes in the document scope selector" do
    select "Passport", from: "Document type"

    expect(page).to have_select("Document country", options: [translated(inner_scope.name), translated(other_organization_scope.name)])
  end
end
