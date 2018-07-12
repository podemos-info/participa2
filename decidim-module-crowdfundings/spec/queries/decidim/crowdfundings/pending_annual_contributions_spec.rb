# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe PendingAnnualContributions do
      let!(:date_limit) { Time.zone.today.beginning_of_month - 11.months }

      let(:subject) { described_class.new.query }

      let!(:old_annual_contribution) do
        create(
          :contribution,
          :annual,
          :accepted,
          last_order_request_date: date_limit - 1.day
        )
      end

      let!(:recent_annual_contribution) do
        create(
          :contribution,
          :annual,
          :accepted,
          last_order_request_date: date_limit
        )
      end

      let!(:pending_annual_contribution) do
        create(
          :contribution,
          :annual,
          :pending,
          last_order_request_date: date_limit - 1.day
        )
      end

      let!(:rejected_annual_contribution) do
        create(
          :contribution,
          :annual,
          :rejected,
          last_order_request_date: date_limit - 1.day
        )
      end

      it "Contains only annual contributions that need to be renewed" do
        expect(subject).to eq([old_annual_contribution])
      end
    end
  end
end
