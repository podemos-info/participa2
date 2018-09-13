# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe RefreshContributions do
      let(:count) { 10 }

      let!(:contributions) do
        create_list(
          :contribution,
          count,
          :punctual,
          :pending,
          payment_method_id: payment_method.id
        )
      end

      let(:payment_method) { create(:payment_method) }

      before do
        stub_payment_method(payment_method)
      end

      it "Retrieves the pending contributions" do
        expect(UnconfirmedContributions).to receive(:new).once.and_call_original
        RefreshContributions.run
      end

      it "Calls refresh command for all pending contributions" do
        expect(RefreshContribution).to receive(:new).exactly(count).times.and_call_original
        RefreshContributions.run
      end
    end
  end
end
