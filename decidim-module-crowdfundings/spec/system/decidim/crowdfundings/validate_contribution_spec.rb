# frozen_string_literal: true

require "spec_helper"

describe "Validate contribution", type: :system do
  include_context "with a component"
  let(:manifest_name) { "crowdfundings" }
  let(:campaign) { create(:campaign, component: component) }

  let(:user) do
    create(:user, :confirmed, :with_person, organization: campaign.organization)
  end

  let!(:contribution) do
    create(
      :contribution,
      :pending,
      campaign: campaign,
      user: user
    )
  end

  let!(:url) do
    ::Decidim::EngineRouter.main_proxy(contribution.campaign.component)
                           .validate_contribution_url(contribution, result: result)
  end

  let(:payment_methods) { create_list(:payment_method, 2) }

  before do
    stub_payment_methods(payment_methods)
    stub_orders_total(0)

    login_as(user, scope: :user)
  end

  context "when contribution was accepted" do
    let(:result) { "ok" }

    before do
      visit(url)
    end

    it "success message" do
      expect(page).to have_content("You have successfully supported the crowdfunding campaign.")
    end
  end

  context "when contribution was rejected" do
    let(:result) { "ko" }

    before do
      visit(url)
    end

    it "success message" do
      expect(page).to have_content("Operation has been denied.")
    end
  end
end
