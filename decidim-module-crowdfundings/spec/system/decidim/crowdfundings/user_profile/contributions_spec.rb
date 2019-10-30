# frozen_string_literal: true

require "spec_helper"

describe "Explore contributions", :vcr, type: :system do
  let(:campaign) { create(:campaign) }
  let(:organization) { campaign.organization }
  let(:user) { create :user, :with_person, :confirmed, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when no contributions found" do
    before do
      visit decidim_crowdfundings_user_profile.contributions_path
    end

    it "Information message shown" do
      expect(page).to have_content("No contributions found")
    end
  end

  context "when contributions found" do
    let!(:contribution) do
      create(:contribution,
             :monthly,
             :accepted,
             user: user,
             campaign: campaign)
    end

    before do
      visit decidim_crowdfundings_user_profile.contributions_path
    end

    it "Table with campaigns found" do
      expect(page).to have_content(campaign.title[:en])
      expect(page).to have_content("Accepted")
      expect(page).to have_content("Monthly")
    end
  end
end
