# frozen_string_literal: true

require "spec_helper"

describe "Explore collaborations", type: :system do
  let(:collaboration) { create(:collaboration) }
  let(:organization) { collaboration.organization }
  let(:user) { create :user, :confirmed, organization: organization }

  let!(:user_collaboration) do
    create(:user_collaboration,
           :monthly,
           :accepted,
           user: user,
           collaboration: collaboration)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_collaborations_user_profile.user_collaborations_path
  end

  it "Link that suspends the user collaboration exists" do
    expect(page).to have_link("", href: decidim_collaborations_user_profile.pause_user_collaboration_path(user_collaboration))
  end

  context "when suspend link visited" do
    before do
      link = find_link("", href: decidim_collaborations_user_profile.pause_user_collaboration_path(user_collaboration))
      link.click
    end

    it "shows a succcess message" do
      expect(page).to have_content("Your collaboration has been successfully suspended.")
    end
  end
end
