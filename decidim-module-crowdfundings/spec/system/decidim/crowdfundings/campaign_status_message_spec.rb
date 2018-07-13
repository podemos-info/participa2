# frozen_string_literal: true

require "spec_helper"

describe "Campaigns view", type: :system do
  include_context "with a component"
  let(:manifest_name) { "crowdfundings" }
  let(:active_until) { nil }
  let!(:campaign) do
    create(:campaign, component: component, active_until: active_until)
  end
  let(:user) { create(:user, :confirmed, organization: organization) }

  before do
    login_as(user, scope: :user)
  end

  context "when API is down" do
    before do
      stub_totals_service_down
      stub_payment_methods_service_down
      visit_component
    end

    it "Gives feedback about status" do
      expect(page).to have_content("Contribution is not allowed at this moment.")
    end
  end

  context "when user has reached his maximum per year" do
    before do
      allow(Census::API::Totals).to receive(:campaign_totals).with(campaign.id).and_return(0)
      allow(Census::API::Totals).to receive(:user_totals)
        .with(user.id)
        .and_return(Decidim::Crowdfundings.maximum_annual_contribution_amount)
      allow(Census::API::Totals).to receive(:user_campaign_totals)
        .with(user.id, campaign.id)
        .and_return(0)
      visit_component
    end

    it "Gives feedback about status" do
      expect(page).to have_content("You can not create more contributions. You have reached the maximum yearly allowed.")
    end
  end

  context "when out of campaign period" do
    let(:active_until) { Time.zone.today - 1.day }

    before do
      stub_totals_request(0)
      visit_component
    end

    it "Gives feedback about status" do
      expect(page).to have_content("The period for accepting contributions has expired.")
    end
  end
end
