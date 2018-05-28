# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Collaborations
    describe RenewUserCollaborations do
      let(:count) { 10 }

      it "Renew is instanced three times" do
        expect(RenewUserCollaborations).to receive(:new).exactly(3).times.and_call_original
        RenewUserCollaborations.run
      end

      it "Retrieves the annual user collaborations" do
        expect(PendingAnnualCollaborations).to receive(:new).once.and_call_original
        RenewUserCollaborations.run
      end

      it "Retrieves the quarterly user collaborations" do
        expect(PendingQuarterlyCollaborations).to receive(:new).once.and_call_original
        RenewUserCollaborations.run
      end

      it "Retrieves the monthly user collaborations" do
        expect(PendingMonthlyCollaborations).to receive(:new).once.and_call_original
        RenewUserCollaborations.run
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

        describe "annual collaborations" do
          let!(:user_collaborations) do
            create_list(
              :user_collaboration,
              count,
              :annual,
              :accepted,
              last_order_request_date: Time.zone.today.beginning_of_month - 11.months - 1.day
            )
          end

          before do
            stub_totals_request(0)
          end

          it "Calls renew command for all pending collaborations" do
            expect(RenewUserCollaboration).to receive(:new).exactly(count).times.and_call_original
            RenewUserCollaborations.run
          end
        end

        describe "quarterly collaborations" do
          let!(:user_collaborations) do
            create_list(
              :user_collaboration,
              count,
              :quarterly,
              :accepted,
              last_order_request_date: Time.zone.today.beginning_of_month - 2.months - 1.day
            )
          end

          before do
            stub_totals_request(0)
          end

          it "Calls renew command for all pending collaborations" do
            expect(RenewUserCollaboration).to receive(:new).exactly(count).times.and_call_original
            RenewUserCollaborations.run
          end
        end

        describe "monthly collaborations" do
          let!(:user_collaborations) do
            create_list(
              :user_collaboration,
              count,
              :monthly,
              :accepted,
              last_order_request_date: Time.zone.today.beginning_of_month - 1.day
            )
          end

          before do
            stub_totals_request(0)
          end

          it "Calls renew command for all pending collaborations" do
            expect(RenewUserCollaboration).to receive(:new).exactly(count).times.and_call_original
            RenewUserCollaborations.run
          end
        end
      end
    end
  end
end
