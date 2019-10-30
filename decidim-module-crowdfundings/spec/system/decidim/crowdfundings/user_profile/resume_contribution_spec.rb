# frozen_string_literal: true

require "spec_helper"

describe "Resume contribution", :vcr, type: :system do
  let(:campaign) { create(:campaign) }
  let(:organization) { campaign.organization }
  let(:user) { create :user, :with_person, :confirmed, organization: organization }

  let!(:contribution) do
    create(:contribution,
           :monthly,
           :paused,
           user: user,
           campaign: campaign)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_crowdfundings_user_profile.contributions_path
  end

  it "Link that resumes the contribution exists" do
    expect(page).to have_link("", href: decidim_crowdfundings_user_profile.resume_contribution_path(contribution))
  end

  context "when resume link visited" do
    before do
      link = find_link("", href: decidim_crowdfundings_user_profile.resume_contribution_path(contribution))
      link.click
    end

    it "shows a success message" do
      expect(page).to have_content("Your contribution has been successfully resumed.")
    end
  end
end
