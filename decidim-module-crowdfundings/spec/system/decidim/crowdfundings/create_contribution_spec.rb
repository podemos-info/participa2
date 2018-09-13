# frozen_string_literal: true

require "spec_helper"

describe "Create contribution", type: :system do
  include_context "with a component"
  let(:manifest_name) { "crowdfundings" }
  let!(:campaign) { create(:campaign, component: component) }
  let(:user) { create(:user, :with_person, :confirmed, organization: organization) }
  let(:amount) { ::Faker::Number.number(4) }

  let(:payment_methods) { create_list(:payment_method, 2) }
  let(:http_status) { 201 }
  let(:order_info) { { payment_method_id: 74 } }

  before do
    stub_payment_methods(payment_methods)
    stub_payment_method(payment_methods.first)
    stub_create_order(order_info, http_status: http_status)
    stub_orders_total(0)

    login_as(user, scope: :user)

    visit_component

    within "#new_contribution" do
      find("label[for=amount_selector_other]").click
      fill_in :contribution_amount, with: amount
    end
  end

  context "with existing payment method" do
    before do
      within "#new_contribution" do
        find("label[for=contribution_payment_method_type_#{payment_methods.first.id}]").click
        find("*[type=submit]").click
      end

      within "#confirm_contribution" do
        find(:css, "#contribution_accept_terms_and_conditions[value='1']").set(true)
        find("*[type=submit]").click
      end
    end

    it "Finish with success message" do
      expect(page).to have_content("You have successfully supported the crowdfunding campaign.")
    end
  end

  context "with direct payment" do
    let(:iban) { "ES5352192642521793064536" }

    before do
      within "#new_contribution" do
        find("label[for=contribution_payment_method_type_direct_debit]").click
        find("*[type=submit]").click
      end

      within "#confirm_contribution" do
        fill_in :contribution_iban, with: iban
        find(:css, "#contribution_accept_terms_and_conditions[value='1']").set(true)
        find("*[type=submit]").click
      end
    end

    it "finishes with success message" do
      expect(page).to have_content("You have successfully supported the crowdfunding campaign.")
    end

    context "when rejected request" do
      let(:http_status) { 422 }
      let(:order_info) { { "iban" => [{ "error" => "invalid" }] } }

      it "Operation fails" do
        expect(page).to have_content("Operation failed.")
      end
    end
  end

  context "with external credit card" do
    let(:http_status) { 202 }
    let(:order_info) do
      {
        payment_method_id: 74,
        form: {
          action: "https://sis-t.redsys.es:25443/sis/realizarPago",
          fields: {
            Ds_MerchantParameters: "In real life this string is very long",
            Ds_SignatureVersion: "HMAC_SHA256_V1",
            Ds_Signature: "1Y8b0LrVOl2v9yD41grkzQ+dDB2yk9umHNai3cZPOsI="
          }
        }
      }
    end

    before do
      within "#new_contribution" do
        find("label[for=contribution_payment_method_type_credit_card_external]").click
        find("*[type=submit]").click
      end

      within "#confirm_contribution" do
        find(:css, "#contribution_accept_terms_and_conditions[value='1']").set(true)
        find("*[type=submit]").click
      end
    end

    it "Redirects to payment platform" do
      expect(page).to have_content("Importe")
      expect(page).to have_content("Código Comercio")
      expect(page).to have_content("Terminal")
      expect(page).to have_content("Número pedido")
    end
  end
end
