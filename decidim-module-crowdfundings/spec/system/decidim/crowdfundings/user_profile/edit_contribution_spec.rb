# frozen_string_literal: true

require "spec_helper"

describe "Edit contribution", type: :system do
  let(:campaign) { create(:campaign) }
  let(:organization) { campaign.organization }
  let(:user) { create :user, :with_person, :confirmed, organization: organization }

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

  context "when edit link visited" do
    before do
      link = find_link("", href: decidim_crowdfundings_user_profile.edit_contribution_path(contribution))
      link.click
    end

    it "Navigates to update form" do
      expect(page).to have_content("Select the amount")
      expect(page).to have_content("Select the frequency")
      expect(page).to have_content("Update")
    end

    it "does not allow changing the contribution to punctual" do
      expect(page).to have_no_content("Puntual")
    end
  end

  context "when updating the contribution" do
    let(:edit_profile_link) do
      find_link("", href: decidim_crowdfundings_user_profile.edit_contribution_path(contribution))
    end

    before do
      stub_orders_total(0)
    end

    context "without changes" do
      before do
        edit_profile_link.click
        find_button("Update").click
      end

      it "shows a success message" do
        expect(page).to have_content("Your contribution has been successfully updated.")
      end
    end

    context "when changing custom amount" do
      before do
        campaign.update!(minimum_custom_amount: 50)
        edit_profile_link.click
        find("label[for=amount_selector_other]").click
      end

      context "with a valid value" do
        before do
          fill_in :contribution_amount, with: 50
          find_button("Update").click
        end

        it "shows a success message" do
          expect(page).to have_content("Your contribution has been successfully updated.")
        end
      end

      context "with an invalid value" do
        before do
          fill_in :contribution_amount, with: 49
          find_button("Update").click
        end

        it "shows proper error messages" do
          expect(page)
            .to have_content("Couldn't update the contribution")
            .and have_content("Minimum valid amount is 50")
        end
      end
    end
  end
end
