# frozen_string_literal: true

require "spec_helper"

describe "Create contribution", type: :system do
  include_context "with a component"
  let(:manifest_name) { "crowdfundings" }
  let!(:campaign) { create(:campaign, component: component) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:amount) { ::Faker::Number.number(4) }

  let(:payment_methods) do
    [
      { id: 1, name: "Payment method 1" },
      { id: 2, name: "Payment method 2" }
    ]
  end

  before do
    stub_payment_methods(payment_methods)
    stub_orders(order_http_response_code, order_response_json)
    stub_totals_request(0)

    login_as(user, scope: :user)

    visit_component

    within ".new_contribution" do
      find("label[for=amount_selector_other]").click
      fill_in :contribution_amount, with: amount
      find(:css, "#contribution_accept_terms_and_conditions[value='1']").set(true)
    end
  end

  describe "Requests without external authorization" do
    let(:order_http_response_code) { 201 }
    let(:order_response_json) { { payment_method_id: 74 } }

    context "with existing payment method" do
      before do
        within ".new_contribution" do
          find("label[for=contribution_payment_method_type_1]").click
          find("*[type=submit]").click
        end

        within ".confirm_contribution" do
          find("*[type=submit]").click
        end

        page.driver.browser.switch_to.alert.accept
      end

      it "Finish with success message" do
        expect(page).to have_content("You have successfully supported the crowdfunding campaign.")
      end
    end

    context "with direct payment" do
      let(:iban) { "ES5352192642521793064536" }

      before do
        within ".new_contribution" do
          find("label[for=contribution_payment_method_type_direct_debit]").click
          find("*[type=submit]").click
        end

        within ".confirm_contribution" do
          fill_in :contribution_iban, with: iban
          find("*[type=submit]").click

          page.driver.browser.switch_to.alert.accept
        end
      end

      it "Finish with success message" do
        expect(page).to have_content("You have successfully supported the crowdfunding campaign.")
      end

      context "when rejected request" do
        let(:order_http_response_code) { 422 }
        let(:order_response_json) { { errorCode: 1234, errorMessage: "error message" } }

        it "Operation fails" do
          expect(page).to have_content("Operation failed.")
        end
      end
    end
  end

  context "with credit card" do
    let(:order_http_response_code) { 202 }
    let(:order_response_json) do
      {
        payment_method_id: 74,
        form: {
          action: "https://sis-t.redsys.es:25443/sis/realizarPago",
          fields: {
            Ds_MerchantParameters: "In real life this string is very long",
            Ds_SignatureVersion: "HMAC_SHA256_V1",
            Ds_Signature: "dNm0D9vbtal+1xWkNyG1PwzYHbE5RY+k6BdKfKogaaE="
          }
        }
      }
    end

    before do
      within ".new_contribution" do
        find("label[for=contribution_payment_method_type_credit_card_external]").click
        find("*[type=submit]").click
      end

      within ".confirm_contribution" do
        find("*[type=submit]").click
      end

      page.driver.browser.switch_to.alert.accept
    end

    it "Redirects to payment platform" do
      expect(page).to have_content("Importe")
      expect(page).to have_content("Código Comercio")
      expect(page).to have_content("Terminal")
      expect(page).to have_content("Número pedido")
    end
  end
end
