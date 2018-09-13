# frozen_string_literal: true

require "spec_helper"

describe "Campaigns view", type: :system do
  include_context "with a component"
  let(:manifest_name) { "crowdfundings" }
  let(:active_until) { nil }
  let!(:campaign) do
    create(:campaign, component: component, active_until: active_until)
  end
  let(:user) { create(:user, :with_person, :confirmed, organization: organization) }

  before do
    login_as(user, scope: :user)
  end

  context "when API is down" do
    before do
      stub_payments_service_down
      visit_component
    end

    it "Gives feedback about status" do
      expect(page).to have_content("We are sorry, the payments system is not working at this moment.")
    end
  end

  context "when user has reached his maximum per year" do
    before do
      stub_orders_total(Decidim::Crowdfundings.maximum_annual_contribution_amount)
      visit_component
    end

    it "Gives feedback about status" do
      expect(page).to have_content("You can not create more contributions. You have reached the maximum yearly allowed.")
    end
  end

  context "when out of campaign period" do
    let(:active_until) { Time.zone.today - 1.day }

    before do
      stub_orders_total(0)
      visit_component
    end

    it "Gives feedback about status" do
      expect(page).to have_content("The period for accepting contributions has expired.")
    end
  end
end
