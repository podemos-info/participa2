# frozen_string_literal: true

require "spec_helper"

describe "Collaborations view", type: :system do
  include_context "with a component"
  let(:manifest_name) { "collaborations" }
  let(:active_until) { nil }
  let!(:collaboration) do
    create(:collaboration, component: component, active_until: active_until)
  end
  let(:user) { create(:user, :confirmed, organization: organization) }

  before do
    login_as(user, scope: :user)
  end

  context "when API is down" do
    before do
      stub_totals_service_down
      visit_component
    end

    it "Gives feedback about status" do
      expect(page).to have_content("Collaboration is not allowed at this moment.")
    end
  end

  context "when user has reached his maximum per year" do
    before do
      allow(Census::API::Totals).to receive(:campaign_totals).with(collaboration.id).and_return(0)
      allow(Census::API::Totals).to receive(:user_totals)
        .with(user.id)
        .and_return(Decidim::Collaborations.maximum_annual_collaboration)
      allow(Census::API::Totals).to receive(:user_campaign_totals)
        .with(user.id, collaboration.id)
        .and_return(0)
      visit_component
    end

    it "Gives feedback about status" do
      expect(page).to have_content("You can not create more collaborations. You have reached the maximum yearly allowed.")
    end
  end

  context "when out of collaboration period" do
    let(:active_until) { Time.zone.today - 1.day }

    before do
      stub_totals_request(0)
      visit_component
    end

    it "Gives feedback about status" do
      expect(page).to have_content("The period for accepting collaborations has expired.")
    end
  end
end
