# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe RenewContribution do
      subject { described_class.new(payments_proxy, contribution).call }

      let(:payments_proxy) { create(:payments_proxy, organization: contribution.campaign.organization) }
      let!(:contribution) do
        create(
          :contribution,
          :annual,
          :accepted,
          last_order_request_date: Time.zone.today - 11.months - 1.day
        )
      end

      describe "valid?" do
        context "when campaign does not accept contributions" do
          before do
            allow(contribution.campaign).to receive(:accepts_contributions?).and_return(false)
          end

          it "is not valid" do
            expect { subject }.to broadcast(:invalid)
          end
        end

        context "when census API is down" do
          before do
            stub_payments_service_down(payments_proxy)
          end

          it "is not valid" do
            expect { subject }.to broadcast(:invalid)
          end
        end

        context "when user has reached the maximum allowed" do
          before do
            stub_orders_total(Decidim::Crowdfundings.maximum_annual_contribution_amount)
          end

          it "is not valid" do
            expect { subject }.to broadcast(:invalid)
          end
        end
      end

      context "when census service is down" do
        before do
          stub_payments_service_down(payments_proxy)
        end

        it "do not updates the contribution" do
          subject
          contribution.reload
          expect(contribution.last_order_request_date).not_to eq(Time.zone.today.beginning_of_month)
        end

        it "is not valid" do
          expect { subject }.to broadcast(:invalid)
        end
      end

      context "when census API rejects the request" do
        before do
          stub_orders_total(0)
          stub_create_order({}, http_status: 422)
        end

        it "do not updates the contribution" do
          subject
          contribution.reload
          expect(contribution.last_order_request_date).not_to eq(Time.zone.today.beginning_of_month)
        end

        it "is not valid" do
          expect { subject }.to broadcast(:invalid)
        end
      end

      context "when everything is ok" do
        let(:order_info) do
          { payment_method_id: contribution.payment_method_id }
        end

        before do
          stub_create_order(order_info)
          stub_orders_total(0)
          subject
          contribution.reload
        end

        it "last_order_request_date is updated" do
          expect(contribution.last_order_request_date).to eq(Time.zone.today.beginning_of_month)
        end
      end
    end
  end
end
