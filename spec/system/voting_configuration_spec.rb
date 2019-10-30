# frozen_string_literal: true

require "rails_helper"

require "decidim/assemblies/test/factories"
require "decidim/votings/test/factories"
require "decidim/census_connector/test/factories"

describe "Votings configuration", type: :system do
  let(:manifest) { Decidim.find_component_manifest("votings") }
  let(:organization) { create(:organization) }
  let(:assembly) { create(:assembly, organization: organization) }
  let(:component) { create(:component, manifest: manifest, participatory_space: assembly, permissions: permissions) }
  let(:scope) { create(:scope, organization: organization) }

  let!(:voting) { create(:voting, :n_votes, component: component, scope: scope) }

  let(:permissions) do
    {
      "vote" => {
        "authorization_handlers" => { "census" => { "options" => options } }
      }
    }
  end

  let(:options) do
    {
      "enforce_scope" => "1"
    }
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit main_component_path(component)
    click_link translated(voting.title)
  end

  context "when the user has not yet registered with Census" do
    let(:user) { create :user, :confirmed, organization: organization }

    it "is prompted to register with census" do
      click_link "Votar"

      expect(page).to have_link('Autorizar con "Censo"')
    end
  end

  context "when the user already registered with Census" do
    let(:user) { create :user, :with_person, :confirmed, organization: organization, scope: user_scope }
    let(:user_scope) { scope }

    it "is allowed to enter the voting booth" do
      click_link "Votar"

      expect(page).to have_link("Cargando cabina de votación...")
    end

    context "when the user scope is different from the voting scope" do
      let(:user_scope) { create(:scope, organization: organization) }

      it "is not allowed to enter the voting booth" do
        click_link "Votar"

        expect(page).to have_content("Debes estar inscrito en el territorio de la actividad.")
      end
    end
  end
end
