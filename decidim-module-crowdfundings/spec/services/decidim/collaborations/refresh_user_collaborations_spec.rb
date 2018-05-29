# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Collaborations
    describe RefreshUserCollaborations do
      let(:count) { 10 }

      let!(:collaborations) do
        create_list(
          :user_collaboration,
          count,
          :punctual,
          :pending
        )
      end

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

      it "Retrieves the pending collaborations" do
        expect(UnconfirmedCollaborations).to receive(:new).once.and_call_original
        RefreshUserCollaborations.run
      end

      it "Calls refresh command for all pending collaborations" do
        expect(RefreshUserCollaboration).to receive(:new).exactly(count).times.and_call_original
        RefreshUserCollaborations.run
      end
    end
  end
end
