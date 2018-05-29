# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Collaborations
    describe RefreshUserCollaboration do
      subject { described_class.new(user_collaboration) }

      let!(:user_collaboration) do
        create(
          :user_collaboration,
          :punctual,
          :pending
        )
      end

      context "when census service is down" do
        before do
          stub_payment_method_service_down
        end

        it "do not updates the collaboration" do
          subject.call
          user_collaboration.reload
          expect(user_collaboration).to be_pending
        end

        it "is not valid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when everything is ok" do
        let(:payment_method) do
          {
            id: 1,
            name: "Existing payment method",
            type: "PaymentMethods::DirectDebit",
            status: status
          }
        end

        before do
          stub_payment_method(payment_method)
          subject.call
          user_collaboration.reload
        end

        context "when active" do
          let(:status) { "active" }

          it "Order status is accepted" do
            expect(user_collaboration).to be_accepted
          end
        end

        context "when inactive" do
          let(:status) { "inactive" }

          it "Order status is rejected" do
            expect(user_collaboration).to be_rejected
          end
        end

        context "when pending" do
          let(:status) { "pending" }

          it "Order status keeps unchanged" do
            expect(user_collaboration).to be_pending
          end
        end
      end
    end
  end
end
