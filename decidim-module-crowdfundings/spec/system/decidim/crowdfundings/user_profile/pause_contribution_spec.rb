# frozen_string_literal: true

require "spec_helper"

describe "Pause contribution", type: :system do
  around do |example|
    VCR.use_cassette(cassette, {}, &example)
  end

  let(:campaign) { create(:campaign) }
  let(:organization) { campaign.organization }
  let(:user) { create :user, :with_person, :confirmed, organization: organization }
  let(:cassette) { "existing_person" }

  let!(:contribution) do
    create(:contribution,
           :monthly,
           :accepted,
           user: user,
           campaign: campaign)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_crowdfundings_user_profile.contributions_path
  end

  it "Link that pauses the contribution exists" do
    expect(page).to have_link("", href: decidim_crowdfundings_user_profile.pause_contribution_path(contribution))
  end

  context "when pause link visited" do
    before do
      link = find_link("", href: decidim_crowdfundings_user_profile.pause_contribution_path(contribution))
      link.click
    end

    it "shows a succcess message" do
      expect(page).to have_content("Your contribution has been successfully suspended.")
    end
  end
end
