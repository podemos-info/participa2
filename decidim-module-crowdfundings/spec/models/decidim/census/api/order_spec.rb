# frozen_string_literal: true

require "spec_helper"

module Census
  module API
    describe Order do
      let(:result) { ::Census::API::Order.create({}) }

      describe "Communication error" do
        before do
          stub_orders_service_down
        end

        it "Returns structure with error code and message" do
          expect(result).to have_key :http_response_code
          expect(result).to have_key :message
        end
      end

      describe "Successful request" do
        before do
          stub_orders(http_response_code, json)
        end

        context "with existing payment method / Direct debit" do
          let(:json) { { payment_method_id: 74 } }
          let(:http_response_code) { 201 }

          it "Response contains the result code" do
            expect(result).to have_key :http_response_code
            expect(result[:http_response_code]).to eq(http_response_code)
          end

          it "Response contains the payment method id" do
            expect(result).to have_key :payment_method_id
            expect(result[:payment_method_id]).to eq(json[:payment_method_id])
          end
        end

        context "with new credit card" do
          let(:http_response_code) { 202 }
          let(:json) do
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

          it "Response contains the result code" do
            expect(result).to have_key :http_response_code
            expect(result[:http_response_code]).to eq(http_response_code)
          end

          it "Response contains the payment method id" do
            expect(result).to have_key :payment_method_id
            expect(result[:payment_method_id]).to eq(json[:payment_method_id])
          end

          it "Response contains redirection form data" do
            expect(result[:form][:action]).to eq(json[:form][:action])
            json[:form][:fields].each do |key, value|
              expect(result[:form][:fields][key]).to eq(value)
            end
          end
        end
      end
    end
  end
end
