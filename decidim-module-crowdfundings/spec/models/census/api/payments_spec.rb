# frozen_string_literal: true

require "spec_helper"

module Census
  module API
    describe Payments do
      let(:instance) { described_class.new }
      let(:qualified_id) { "#{person_id}@census" }
      let(:person_id) { 1 }

      let(:http_status) { 200 }
      let(:result) { response.first }
      let(:info) { response.last }

      shared_examples "handles when census is down" do
        context "when census is down" do
          before { stub_payments_service_down(instance) }

          it "returns an error code and an empty hash" do
            expect(result).to eq(:error)
            expect(info).to eq({})
          end
        end
      end

      describe "create order" do
        subject(:response) { instance.create_order(qualified_id, amount: 1) }

        let(:order_info) { { payment_method_id: 74 } }
        let(:http_status) { 201 }

        before { stub_create_order(order_info, http_status: http_status) }

        it_behaves_like "handles when census is down"

        it "returns ok and the payment method id" do
          expect(result).to eq(:ok)
          expect(info[:payment_method_id]).to eq(order_info[:payment_method_id])
        end

        context "with new credit card" do
          let(:http_status) { 202 }
          let(:order_info) do
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

          it "returns ok, the payment method id and the redirection form data" do
            expect(result).to eq(:ok)
            expect(info[:payment_method_id]).to eq(order_info[:payment_method_id])
            expect(info[:form][:action]).to eq(order_info[:form][:action])
            order_info[:form][:fields].each do |key, value|
              expect(info[:form][:fields][key]).to eq(value)
            end
          end
        end
      end

      describe "retrieve person payment methods" do
        subject(:response) { instance.payment_methods(qualified_id) }

        let(:payment_methods_data) { create_list(:payment_method, 2) }

        before { stub_payment_methods(payment_methods_data, http_status: http_status) }

        it_behaves_like "handles when census is down"

        it "returns ok and the list of payment methods" do
          expect(result).to eq(:ok)
          info.zip(payment_methods_data).each do |payment_method, payment_method_data|
            %w(id name type status verified?).each do |attribute|
              expect(payment_method.send(attribute)).to eq(payment_method_data.send(attribute))
            end
          end
        end

        context "when there is no person" do
          let(:http_status) { 422 }

          it "returns invalid and an empty hash" do
            expect(result).to eq(:invalid)
            expect(info).to eq(errors: {})
          end
        end
      end

      describe "retrieve a payment method" do
        subject(:response) { instance.payment_method(payment_method_id) }

        let(:payment_method) { create(:payment_method) }
        let(:payment_method_id) { payment_method.id }

        before { stub_payment_method(payment_method, http_status: http_status, payment_method_id: payment_method_id) }

        it_behaves_like "handles when census is down"

        it "returns ok and the payment method info" do
          expect(result).to eq(:ok)
          %w(id name type status verified?).each do |attribute|
            expect(info.send(attribute)).to eq(payment_method.send(attribute))
          end
        end

        context "when there is no payment method id" do
          let(:payment_method_id) { nil }

          it "returns invalid and an empty hash" do
            expect(result).to eq(:invalid)
            expect(info).to eq({})
          end
        end

        context "when the payment method doesn't exist" do
          let(:http_status) { 404 }

          it "returns error and an empty hash" do
            expect(result).to eq(:error)
            expect(info).to eq({})
          end
        end
      end

      describe "retrieve orders totals" do
        subject(:response) { instance.orders_total(params) }

        let(:amount) { 50 }
        let(:params) { { campaign_code: "TEST" } }

        before { stub_orders_total(amount, http_status: http_status) }

        it_behaves_like "handles when census is down"

        it "returns ok and the amount" do
          expect(result).to eq(:ok)
          expect(info).to eq(amount)
        end

        context "when filtering for a user" do
          let(:params) { { person_id: qualified_id } }

          it "returns ok and the amount" do
            expect(result).to eq(:ok)
            expect(info).to eq(amount)
          end
        end

        context "when filtering for a user and a campaign" do
          let(:params) { { person_id: qualified_id, campaign_code: "TEST" } }

          it "returns ok and the amount" do
            expect(result).to eq(:ok)
            expect(info).to eq(amount)
          end
        end

        context "when there is no filter" do
          let(:http_status) { 422 }

          it "returns invalid and an empty hash" do
            expect(result).to eq(:invalid)
            expect(info).to eq(errors: {})
          end
        end
      end
    end
  end
end
