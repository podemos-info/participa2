# frozen_string_literal: true

require "spec_helper"

describe "Confirm user collaboration", type: :system do
  include_context "with a component"
  let(:manifest_name) { "collaborations" }
  let(:collaboration) { create(:collaboration, component: component) }

  let(:user) do
    create(:user, :confirmed, organization: collaboration.organization)
  end

  let!(:user_collaboration) do
    create(
      :user_collaboration,
      :pending,
      collaboration: collaboration,
      user: user
    )
  end

  let!(:url) do
    ::Decidim::EngineRouter.main_proxy(user_collaboration.collaboration.component)
                           .validate_user_collaboration_url(user_collaboration, result: result)
  end

  let(:payment_methods) do
    [
      { id: 1, name: "Payment method 1" },
      { id: 2, name: "Payment method 2" }
    ]
  end

  before do
    stub_payment_methods(payment_methods)
    stub_totals_request(0)

    login_as(user, scope: :user)
  end

  context "when collaboration accepted" do
    let(:result) { "ok" }

    before do
      visit(url)
    end

    it "success message" do
      expect(page).to have_content("You have successfully supported the collaboration campaign.")
    end
  end

  context "when collaboration rejected" do
    let(:result) { "ko" }

    before do
      visit(url)
    end

    it "success message" do
      expect(page).to have_content("Operation has been denied.")
    end
  end
end
