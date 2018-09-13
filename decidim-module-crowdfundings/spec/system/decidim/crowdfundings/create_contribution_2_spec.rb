# frozen_string_literal: true

require "spec_helper"

describe "Create contribution 2", type: :system do
  include_context "with a component"
  let(:manifest_name) { "crowdfundings" }
  let!(:campaign) { create(:campaign, component: component) }
  let(:user) { create(:user, :with_person, :confirmed, organization: organization) }
  let(:amount) { ::Faker::Number.number(4) }

  let(:payment_methods) { create_list(:payment_method, 2) }

  before do
    stub_payment_methods(payment_methods)
    stub_payment_method(payment_methods.first)
    stub_orders_total(0)

    login_as(user, scope: :user)

    visit_component

    within "#new_contribution" do
      find("label[for=amount_selector_other]").click
      fill_in :contribution_amount, with: amount
    end
  end

  describe "filling campaign form" do
    context "with existing payment method" do
      before do
        within "#new_contribution" do
          find("label[for=contribution_payment_method_type_#{payment_methods.first.id}]").click
          find("*[type=submit]").click
        end
      end

      it "navigates to confirm page" do
        expect(page).to have_content("Contribution resume")
      end

      it "Shows the amount" do
        expect(page).to have_content(decidim_number_to_currency(amount))
      end

      it "Shows the frequency" do
        expect(page).to have_content("PUNCTUAL")
      end

      it "Shows the payment method name" do
        expect(page).to have_content(payment_methods.first.name.upcase)
      end

      it "No extra fields are needed" do
        expect(page).not_to have_content("Fill the following fields")
      end
    end

    context "with direct debit" do
      before do
        within "#new_contribution" do
          find("label[for=contribution_payment_method_type_direct_debit]").click
          find("*[type=submit]").click
        end
      end

      it "navigates to confirm page" do
        expect(page).to have_content("Contribution resume")
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
        expect(page).to have_content("Fill the following fields")
        expect(page).to have_field("IBAN")
      end
    end

    context "with credit card" do
      before do
        within "#new_contribution" do
          find("label[for=contribution_payment_method_type_credit_card_external]").click
          find("*[type=submit]").click
        end
      end

      it "navigates to confirm page" do
        expect(page).to have_content("Contribution resume")
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
        expect(page).not_to have_content("Fill the following fields")
      end
    end

    context "when no payment method selected" do
      before do
        within "#new_contribution" do
          find("*[type=submit]").click
        end
      end

      it "renders the form again" do
        expect(page).to have_content("Select the payment method")
      end

      it "shows an error message" do
        expect(page).to have_content("You must select a payment method.")
      end
    end
  end
end
