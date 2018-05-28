# frozen_string_literal: true

require "spec_helper"

describe "Collaborations view", type: :system do
  let(:manifest_name) { "collaborations" }
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
    let!(:collaboration) { create(:collaboration, component: component) }
    let!(:user_collaboration) do
      create(:user_collaboration,
             :accepted,
             :punctual,
             collaboration: collaboration,
             user: confirmed_user,
             amount: amount)
    end

    before do
      login_as(confirmed_user, scope: :user)
      visit_component
    end

    it "Contains collaboration details" do
      expect(page).to have_content(translated(collaboration.title))
      expect(page).to have_content(strip_tags(translated(collaboration.description)))
    end

    it "Contains totals" do
      within "#overall-totals-block" do
        expect(page).to have_content(decidim_number_to_currency(collaboration.total_collected))
        expect(page).to have_content("OVERALL PERCENTAGE: #{number_to_percentage(collaboration.percentage, precision: 0)}")
        expect(page).to have_content(decidim_number_to_currency(collaboration.target_amount))
      end
    end

    it "Frequency is punctual by default" do
      frequency = find(:css, "#user_collaboration_frequency", visible: false)
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

    let!(:collaboration) do
      create(:collaboration, component: component, target_amount: 10_000)
    end

    before do
      login_as(confirmed_user, scope: :user)
    end

    context "when the user has a recurrent collaboration" do
      let!(:user_collaboration) do
        create(:user_collaboration,
               :accepted,
               :monthly,
               collaboration: collaboration,
               user: confirmed_user,
               amount: amount)
      end

      before do
        visit_component
      end

      it "allows the user to change the recurrent collaboration" do
        expect(page).to have_content("You are currently giving 500.00 € with monthly periodicity")

        expect(page).to have_content("CHANGE COLLABORATION")

        within find("#collaboration-info") do
          click_link "change collaboration"
        end

        find("label[for=user_collaboration_frequency_quarterly]").click
        click_button "Update"

        expect(page).to have_content("You are currently giving 500.00 € with quarterly periodicity")
      end
    end

    context "when the user does not have a recurrent collaboration" do
      before do
        visit_component
      end

      it "Frequency is monthly by default" do
        amount = find(
          :radio_button,
          "user_collaboration[frequency]",
          checked: true,
          visible: false
        )
        expect(amount.value).to eq("monthly")
      end
    end
  end
end
