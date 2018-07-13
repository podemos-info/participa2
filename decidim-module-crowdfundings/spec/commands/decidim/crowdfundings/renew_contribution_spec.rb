# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe RenewContribution do
      subject { described_class.new(contribution) }

      let!(:contribution) do
        create(
          :contribution,
          :annual,
          :accepted,
          last_order_request_date: Time.zone.today - 11.months - 1.day
        )
      end

      describe "valid?" do
        context "when campaign does not accept supports" do
          before do
            allow(contribution.campaign).to receive(:accepts_supports?).and_return(false)
          end

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when census API is down" do
          before do
            stub_totals_service_down
          end

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when user has reached the maximum allowed" do
          before do
            stub_totals_request(Decidim::Crowdfundings.maximum_annual_contribution_amount)
          end

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end
      end

      context "when census service is down" do
        before do
          stub_orders_service_down
          stub_totals_service_down
        end

        it "do not updates the contribution" do
          subject.call
          contribution.reload
          expect(contribution.last_order_request_date).not_to eq(Time.zone.today.beginning_of_month)
        end

        it "is not valid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when census API rejects the request" do
        before do
          stub_totals_request(0)
          stub_orders(422, errorCode: 1, errorMessage: "Error message")
        end

        it "do not updates the contribution" do
          subject.call
          contribution.reload
          expect(contribution.last_order_request_date).not_to eq(Time.zone.today.beginning_of_month)
        end

        it "is not valid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when everything is ok" do
        let(:json) do
          { payment_method_id: contribution.payment_method_id }
        end

        before do
          stub_orders(201, json)
          stub_totals_request(0)
          subject.call
          contribution.reload
        end

        it "last_order_request_date is updated" do
          expect(contribution.last_order_request_date).to eq(Time.zone.today.beginning_of_month)
        end
      end
    end
  end
end
