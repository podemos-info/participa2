# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe CreateContribution do
      subject { described_class.new(payments_proxy, form).call }

      let(:organization) { create(:organization) }
      let(:participatory_process) { create :participatory_process, organization: organization }
      let(:current_component) { create :crowdfundings_component, participatory_space: participatory_process }
      let(:campaign) { create(:campaign, component: current_component) }
      let(:payments_proxy) { create(:payments_proxy, organization: organization) }
      let(:user) { payments_proxy.user }

      let(:context) do
        {
          current_organization: organization,
          current_component: current_component,
          campaign: campaign,
          current_user: user,
          payments_proxy: payments_proxy
        }
      end

      let(:amount) { ::Faker::Number.number(4).to_i }
      let(:frequency) { "punctual" }
      let(:payment_method_type) { "existing_payment_method" }
      let(:payment_method_id) { 1 }
      let(:payment_method) { create(:payment_method, id: 1) }

      let(:iban) { nil }
      let(:external_credit_card_return_url) { "https://example.org/validate/__RESULT__" }

      let(:over_18) { true }
      let(:accept_terms_and_conditions) { true }

      let(:form) do
        ConfirmContributionForm
          .new(
            amount: amount,
            frequency: frequency,
            payment_method_type: payment_method_type,
            payment_method_id: payment_method_id,
            iban: iban,
            external_credit_card_return_url: external_credit_card_return_url,
            over_18: over_18,
            accept_terms_and_conditions: accept_terms_and_conditions
          ).with_context(context)
      end

      let(:order_info) { { payment_method_id: payment_method_id } }
      let(:http_status) { 201 }
      let(:contribution) { Decidim::Crowdfundings::Contribution.last }

      before do
        stub_orders_total(0)
        stub_create_order(order_info, http_status: http_status)
        stub_payment_method(payment_method)
      end

      context "with existing payment method / Direct debit" do
        it "creates the contribution" do
          expect { subject }.to change { Decidim::Crowdfundings::Contribution.count }.by(1)
        end

        it "is valid" do
          expect { subject }.to broadcast(:ok)
        end

        it "Created contribution is accepted" do
          subject
          expect(contribution).to be_accepted
        end

        it "Sets all attributes received from the form" do
          subject
          expect(contribution.amount.to_i).to eq(amount)
          expect(contribution.frequency).to eq(frequency)
          expect(contribution.campaign).to eq(campaign)
          expect(contribution.user).to eq(user)
        end

        it "Last request date is set to the first of the month when happened" do
          subject
          expect(contribution.last_order_request_date).to eq(Time.zone.today.beginning_of_month)
        end
      end

      context "with external credit card" do
        let(:payment_method_type) { "credit_card_external" }
        let(:returned_payment_method_id) { 74 }
        let(:order_info) do
          {
            payment_method_id: returned_payment_method_id,
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
        let(:http_status) { 202 }

        it "creates the contribution" do
          expect { subject }.to change { Decidim::Crowdfundings::Contribution.count }.by(1)
        end

        it "broadcast credit card response" do
          expect { subject }.to broadcast(:credit_card, order_info[:form])
        end

        it "Created contribution is pending" do
          subject
          expect(contribution).to be_pending
        end

        it "Payment method id is set with the value received from census" do
          subject
          expect(contribution.payment_method_id).to eq(returned_payment_method_id)
        end
      end

      context "when the form is not valid" do
        before do
          allow(form).to receive(:valid?).and_return(false)
        end

        it "is not valid" do
          expect { subject }.to broadcast(:invalid)
        end
      end

      context "when census service is down" do
        before do
          stub_payments_service_down(payments_proxy)
        end

        it "do not creates the contribution" do
          expect { subject }.to change { Decidim::Crowdfundings::Contribution.count }.by(0)
        end

        it "is not valid" do
          expect { subject }.to broadcast(:invalid)
        end
      end

      context "when census API rejects the request" do
        let(:http_status) { 422 }
        let(:order_info) { {} }

        it "do not creates the contribution" do
          expect { subject }.to change { Decidim::Crowdfundings::Contribution.count }.by(0)
        end

        it "is not valid" do
          expect { subject }.to broadcast(:invalid)
        end
      end
    end
  end
end
