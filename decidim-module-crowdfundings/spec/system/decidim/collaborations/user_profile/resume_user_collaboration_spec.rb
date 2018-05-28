# frozen_string_literal: true

require "spec_helper"

describe "Explore collaborations", type: :system do
  let(:collaboration) { create(:collaboration) }
  let(:organization) { collaboration.organization }
  let(:user) { create :user, :confirmed, organization: organization }

  let!(:user_collaboration) do
    create(:user_collaboration,
           :monthly,
           :paused,
           user: user,
           collaboration: collaboration)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_collaborations_user_profile.user_collaborations_path
  end

  it "Link that resumes the user collaboration exists" do
    expect(page).to have_link("", href: decidim_collaborations_user_profile.resume_user_collaboration_path(user_collaboration))
  end

  context "when resume link visited" do
    before do
      link = find_link("", href: decidim_collaborations_user_profile.resume_user_collaboration_path(user_collaboration))
      link.click
    end

    it "shows a success message" do
      expect(page).to have_content("Your collaboration has been successfully resumed.")
    end
  end
end
