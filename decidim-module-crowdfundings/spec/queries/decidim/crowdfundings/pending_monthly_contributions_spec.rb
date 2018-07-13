# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe PendingMonthlyContributions do
      let(:beginning_of_month) { Time.zone.today.beginning_of_month }

      let(:subject) { described_class.new.query }

      let!(:annual_contributions) do
        create(
          :contribution,
          :annual,
          :accepted,
          last_order_request_date: beginning_of_month - 11.months - 1.day
        )
      end

      let!(:quarterly_contribution) do
        create(
          :contribution,
          :quarterly,
          :accepted,
          last_order_request_date: beginning_of_month - 2.months - 1.day
        )
      end

      let!(:old_contribution) do
        create(
          :contribution,
          :monthly,
          :accepted,
          last_order_request_date: beginning_of_month - 1.day
        )
      end

      let!(:recent_contribution) do
        create(
          :contribution,
          :monthly,
          :accepted,
          last_order_request_date: beginning_of_month
        )
      end

      let!(:pending_contribution) do
        create(
          :contribution,
          :monthly,
          :pending,
          last_order_request_date: beginning_of_month - 1.day
        )
      end

      let!(:rejected_contributions) do
        create(
          :contribution,
          :monthly,
          :rejected,
          last_order_request_date: beginning_of_month - 1.day
        )
      end

      it "Contains only contributions that need to be renewed" do
        expect(subject).to eq([old_contribution])
      end
    end
  end
end
