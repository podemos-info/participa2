# frozen_string_literal: true

require "spec_helper"

describe "Campaign view", type: :system do
  let(:manifest_name) { "crowdfundings" }
  let(:confirmed_user) { create(:user, :confirmed, organization: organization) }

  let(:payment_methods) do
    [
      { id: 1, name: "Payment method 1" },
      { id: 2, name: "Payment method 2" }
    ]
  end

  let(:amount) { 500 }

  before do
    stub_payment_methods(payment_methods)
    stub_totals_request(500)
  end

  context "with a participatory process" do
    include_context "with a component"
    let!(:campaign) { create(:campaign, component: component) }
    let!(:contribution) do
      create(:contribution,
             :accepted,
             :punctual,
             campaign: campaign,
             user: confirmed_user,
             amount: amount)
    end

    before do
      login_as(confirmed_user, scope: :user)
      visit_component
    end

    it "Contains campaign details" do
      expect(page).to have_content(translated(campaign.title))
      expect(page).to have_content(strip_tags(translated(campaign.description)))
    end

    it "Contains totals" do
      within "#overall-totals-block" do
        expect(page).to have_content(decidim_number_to_currency(campaign.total_collected))
        expect(page).to have_content("OVERALL PERCENTAGE: #{number_to_percentage(campaign.percentage, precision: 0)}")
        expect(page).to have_content(decidim_number_to_currency(campaign.target_amount))
      end
    end

    it "Frequency is punctual by default" do
      frequency = find(:css, "#contribution_frequency", visible: false)
      expect(frequency.value).to eq("punctual")
    end

    it "User payment methods are selectable" do
      payment_methods.each do |method|
        expect(page).to have_content(method[:name])
      end
    end
  end

  context "with an assembly" do
    include_context "with assembly component"

    let!(:campaign) do
      create(:campaign, component: component, target_amount: 10_000)
    end

    before do
      login_as(confirmed_user, scope: :user)
    end

    context "when the user has a recurrent contribution" do
      let!(:contribution) do
        create(:contribution,
               :accepted,
               :monthly,
               campaign: campaign,
               user: confirmed_user,
               amount: amount)
      end

      before do
        visit_component
      end

      it "allows the user to change the recurrent contribution" do
        expect(page).to have_content("You are currently giving 500.00 € with monthly periodicity")

        expect(page).to have_content("CHANGE CONTRIBUTION")

        within find("#contribution-info") do
          click_link "change contribution"
        end

        find("label[for=contribution_frequency_quarterly]").click
        click_button "Update"

        expect(page).to have_content("You are currently giving 500.00 € with quarterly periodicity")
      end
    end

    context "when the user does not have a recurrent contribution" do
      before do
        visit_component
      end

      it "Frequency is monthly by default" do
        amount = find(
          :radio_button,
          "contribution[frequency]",
          checked: true,
          visible: false
        )
        expect(amount.value).to eq("monthly")
      end
    end
  end
end
