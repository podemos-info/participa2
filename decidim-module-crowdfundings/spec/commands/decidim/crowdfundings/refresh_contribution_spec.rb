# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe RefreshContribution do
      subject { described_class.new(payments_proxy, contribution) }

      let(:payments_proxy) { create(:payments_proxy, organization: contribution.campaign.organization) }
      let(:payment_method) { create(:payment_method) }
      let(:contribution) do
        create(
          :contribution,
          :punctual,
          :pending,
          payment_method_id: payment_method.id
        )
      end

      context "when census service is down" do
        before do
          stub_payments_service_down(payments_proxy)
        end

        it "do not updates the contribution" do
          subject.call
          contribution.reload
          expect(contribution).to be_pending
        end

        it "is not valid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when everything is ok" do
        before do
          stub_payment_method(payment_method)
          subject.call
          contribution.reload
        end

        it "sets contribution as accepted" do
          expect(contribution).to be_accepted
        end

        context "when inactive" do
          let(:payment_method) { create(:payment_method, :inactive) }

          it "sets contribution as inactive" do
            expect(contribution).to be_rejected
          end
        end

        context "when incomplete" do
          let(:payment_method) { create(:payment_method, :incomplete) }

          it "lets contribution as pending" do
            expect(contribution).to be_pending
          end
        end
      end
    end
  end
end
