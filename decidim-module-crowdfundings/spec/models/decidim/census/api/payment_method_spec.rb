# frozen_string_literal: true

require "spec_helper"

module Census
  module API
    describe PaymentMethod do
      describe "Payment methods" do
        let(:person_id) { 1 }
        let(:result) { ::Census::API::PaymentMethod.for_user(person_id) }

        context "when communication error" do
          before do
            stub_payment_methods_service_down
          end

          it "Returns structure with error code and message" do
            expect(result).to be_empty
          end
        end

        context "when error response" do
          before do
            stub_payment_methods_error
          end

          it "Returns structure with error code and message" do
            expect(result).to be_empty
          end
        end

        context "when successful response" do
          let(:payment_methods) do
            [
              { id: 1, name: "Payment method 1" },
              { id: 2, name: "Payment method 2" }
            ]
          end

          before do
            stub_payment_methods(payment_methods)
          end

          it "returns the list of payment methods" do
            expect(result).to eq(payment_methods)
          end
        end
      end

      describe "Payment method" do
        let(:result) { ::Census::API::PaymentMethod.payment_method(1) }

        context "with communication error" do
          before do
            stub_payment_method_service_down
          end

          it "Returns structure with error code and message" do
            expect(result).to have_key(:http_response_code)
            expect(result[:http_response_code]).not_to eq(200)
          end
        end

        context "with successful response" do
          let(:payment_method) do
            {
              id: 1,
              name: "Existing payment method",
              type: "PaymentMethods::DirectDebit",
              status: "active"
            }
          end

          before do
            stub_payment_method(payment_method)
          end

          it "returns the list of payment methods" do
            expect(result).to have_key(:http_response_code)
            expect(result[:http_response_code]).to eq(200)

            expect(result.except(:http_response_code)).to eq(payment_method)
          end
        end
      end
    end
  end
end
