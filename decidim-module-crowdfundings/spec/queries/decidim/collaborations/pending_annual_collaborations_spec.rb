# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Collaborations
    describe PendingAnnualCollaborations do
      let!(:date_limit) { Time.zone.today.beginning_of_month - 11.months }

      let(:subject) { described_class.new.query }

      let!(:old_annual_collaboration) do
        create(
          :user_collaboration,
          :annual,
          :accepted,
          last_order_request_date: date_limit - 1.day
        )
      end

      let!(:recent_annual_collaboration) do
        create(
          :user_collaboration,
          :annual,
          :accepted,
          last_order_request_date: date_limit
        )
      end

      let!(:pending_annual_collaboration) do
        create(
          :user_collaboration,
          :annual,
          :pending,
          last_order_request_date: date_limit - 1.day
        )
      end

      let!(:rejected_annual_collaboration) do
        create(
          :user_collaboration,
          :annual,
          :rejected,
          last_order_request_date: date_limit - 1.day
        )
      end

      it "Contains only annual collaborations that need to be renewed" do
        expect(subject).to eq([old_annual_collaboration])
      end
    end
  end
end
