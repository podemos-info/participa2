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

  context "when edit link visited" do
    before do
      link = find_link("", href: decidim_collaborations_user_profile.edit_user_collaboration_path(user_collaboration))
      link.click
    end

    it "Navigates to update form" do
      expect(page).to have_content("SELECT THE AMOUNT")
      expect(page).to have_content("SELECT THE FREQUENCY")
      expect(page).to have_content("UPDATE")
    end

    it "does not allow changing the collaboration to punctual" do
      expect(page).to have_no_content("Puntual")
    end
  end

  context "when updating user collaboration" do
    let(:edit_profile_link) do
      find_link("", href: decidim_collaborations_user_profile.edit_user_collaboration_path(user_collaboration))
    end

    before do
      stub_totals_request(0)
    end

    context "without changes" do
      before do
        edit_profile_link.click
        find_button("Update").click
      end

      it "shows a success message" do
        expect(page).to have_content("Your collaboration has been successfully updated.")
      end
    end

    context "when changing custom amount" do
      before do
        collaboration.update!(minimum_custom_amount: 50)
        edit_profile_link.click
        find("label[for=amount_selector_other]").click
      end

      context "with a valid value" do
        before do
          fill_in :user_collaboration_amount, with: 50
          find_button("Update").click
        end

        it "shows a success message" do
          expect(page).to have_content("Your collaboration has been successfully updated.")
        end
      end

      context "with an invalid value" do
        before do
          fill_in :user_collaboration_amount, with: 49
          find_button("Update").click
        end

        it "shows proper error messages" do
          expect(page)
            .to have_content("Couldn't update the collaboration")
            .and have_content("Minimum valid amount is 50")
        end
      end
    end
  end
end
