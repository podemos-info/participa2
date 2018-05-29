# frozen_string_literal: true

require "spec_helper"

describe "Explore collaborations", type: :system do
  let(:collaboration) { create(:collaboration) }
  let(:organization) { collaboration.organization }
  let(:user) { create :user, :confirmed, organization: organization }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  context "when no collaborations found" do
    before do
      visit decidim_collaborations_user_profile.user_collaborations_path
    end

    it "Information message shown" do
      expect(page).to have_content("No collaborations found")
    end
  end

  context "when collaborations found" do
    let!(:user_collaboration) do
      create(:user_collaboration,
             :monthly,
             :accepted,
             user: user,
             collaboration: collaboration)
    end

    before do
      page.visit decidim_collaborations_user_profile.user_collaborations_path
    end

    it "Table with collaborations found" do
      expect(page).to have_content(collaboration.title[:en])
      expect(page).to have_content("Accepted")
      expect(page).to have_content("Monthly")
    end
  end
end
