# frozen_string_literal: true

require "spec_helper"

describe "Confirm collaboration", type: :system do
  include_context "with a component"
  let(:manifest_name) { "collaborations" }
  let!(:collaboration) { create(:collaboration, component: component) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:amount) { ::Faker::Number.number(4) }

  let(:existing_payment_methods) do
    [
      { id: 1, name: "Existing payment method" }
    ]
  end

  before do
    stub_payment_methods(existing_payment_methods)
    stub_totals_request(0)

    login_as(user, scope: :user)

    visit_component

    within ".new_user_collaboration" do
      find("label[for=amount_selector_other]").click
      fill_in :user_collaboration_amount, with: amount
      find(:css, "#user_collaboration_over_18[value='1']").set(true)
      find(:css, "#user_collaboration_accept_terms_and_conditions[value='1']").set(true)
    end
  end

  describe "filling collaboration form" do
    context "with existing payment method" do
      before do
        within ".new_user_collaboration" do
          find("label[for=user_collaboration_payment_method_type_1]").click
          find("*[type=submit]").click
        end
      end

      it "navigates to confirm page" do
        expect(page).to have_content("COLLABORATION RESUME")
      end

      it "Shows the amount" do
        expect(page).to have_content(decidim_number_to_currency(amount))
      end

      it "Shows the frequency" do
        expect(page).to have_content("PUNCTUAL")
      end

      it "Shows the payment method" do
        expect(page).to have_content("EXISTING PAYMENT METHOD")
      end

      it "No extra fields are needed" do
        expect(page).not_to have_content("FILL THE FOLLOWING FIELDS")
      end
    end

    context "with direct debit" do
      before do
        within ".new_user_collaboration" do
          find("label[for=user_collaboration_payment_method_type_direct_debit]").click
          find("*[type=submit]").click
        end
      end

      it "navigates to confirm page" do
        expect(page).to have_content("COLLABORATION RESUME")
      end

      it "Shows the amount" do
        expect(page).to have_content(decidim_number_to_currency(amount))
      end

      it "Shows the frequency" do
        expect(page).to have_content("PUNCTUAL")
      end

      it "Shows the payment method" do
        expect(page).to have_content("DIRECT DEBIT")
      end

      it "IBAN needed" do
        expect(page).to have_content("FILL THE FOLLOWING FIELDS")
        expect(page).to have_field("IBAN")
      end
    end

    context "with credit card" do
      before do
        within ".new_user_collaboration" do
          find("label[for=user_collaboration_payment_method_type_credit_card_external]").click
          find("*[type=submit]").click
        end
      end

      it "navigates to confirm page" do
        expect(page).to have_content("COLLABORATION RESUME")
      end

      it "Shows the amount" do
        expect(page).to have_content(decidim_number_to_currency(amount))
      end

      it "Shows the frequency" do
        expect(page).to have_content("PUNCTUAL")
      end

      it "Shows the payment method" do
        expect(page).to have_content("CREDIT CARD")
      end

      it "No extra fields are needed" do
        expect(page).not_to have_content("FILL THE FOLLOWING FIELDS")
      end
    end

    context "when no payment method selected" do
      before do
        within ".new_user_collaboration" do
          find("*[type=submit]").click
        end
      end

      it "renders the form again" do
        expect(page).to have_content("SELECT THE PAYMENT METHOD")
      end

      it "shows an error message" do
        expect(page).to have_content("You must select a payment method.")
      end
    end
  end
end
