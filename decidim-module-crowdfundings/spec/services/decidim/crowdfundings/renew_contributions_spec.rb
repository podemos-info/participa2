# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe RenewContributions do
      let(:count) { 10 }

      it "Renew is instanced three times" do
        expect(RenewContributions).to receive(:new).exactly(3).times.and_call_original
        RenewContributions.run
      end

      it "Retrieves the annual contributions" do
        expect(PendingAnnualContributions).to receive(:new).once.and_call_original
        RenewContributions.run
      end

      it "Retrieves the quarterly contributions" do
        expect(PendingQuarterlyContributions).to receive(:new).once.and_call_original
        RenewContributions.run
      end

      it "Retrieves the monthly contributions" do
        expect(PendingMonthlyContributions).to receive(:new).once.and_call_original
        RenewContributions.run
      end

      describe "Renew process" do
        let(:json) do
          { payment_method_id: ::Faker::Number.number(4).to_i }
        end

        before do
          stub_request(:post, %r{/api/v1/payments/orders})
            .to_return(
              status: 201,
              body: json.to_json,
              headers: {}
            )
        end

        describe "annual contributions" do
          let!(:contributions) do
            create_list(
              :contribution,
              count,
              :annual,
              :accepted,
              last_order_request_date: Time.zone.today.beginning_of_month - 11.months - 1.day
            )
          end

          before do
            stub_orders_total(0)
          end

          it "Calls renew command for all pending contributions" do
            expect(RenewContribution).to receive(:new).exactly(count).times.and_call_original
            RenewContributions.run
          end
        end

        describe "quarterly contributions" do
          let!(:contributions) do
            create_list(
              :contribution,
              count,
              :quarterly,
              :accepted,
              last_order_request_date: Time.zone.today.beginning_of_month - 2.months - 1.day
            )
          end

          before do
            stub_orders_total(0)
          end

          it "Calls renew command for all pending contributions" do
            expect(RenewContribution).to receive(:new).exactly(count).times.and_call_original
            RenewContributions.run
          end
        end

        describe "monthly contributions" do
          let!(:contributions) do
            create_list(
              :contribution,
              count,
              :monthly,
              :accepted,
              last_order_request_date: Time.zone.today.beginning_of_month - 1.day
            )
          end

          before do
            stub_orders_total(0)
          end

          it "Calls renew command for all pending contributions" do
            expect(RenewContribution).to receive(:new).exactly(count).times.and_call_original
            RenewContributions.run
          end
        end
      end
    end
  end
end
