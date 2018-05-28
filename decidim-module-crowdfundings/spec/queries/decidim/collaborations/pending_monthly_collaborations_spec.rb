# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Collaborations
    describe PendingMonthlyCollaborations do
      let(:beginning_of_month) { Time.zone.today.beginning_of_month }

      let(:subject) { described_class.new.query }

      let!(:annual_collaborations) do
        create(
          :user_collaboration,
          :annual,
          :accepted,
          last_order_request_date: beginning_of_month - 11.months - 1.day
        )
      end

      let!(:quarterly_collaboration) do
        create(
          :user_collaboration,
          :quarterly,
          :accepted,
          last_order_request_date: beginning_of_month - 2.months - 1.day
        )
      end

      let!(:old_collaboration) do
        create(
          :user_collaboration,
          :monthly,
          :accepted,
          last_order_request_date: beginning_of_month - 1.day
        )
      end

      let!(:recent_collaboration) do
        create(
          :user_collaboration,
          :monthly,
          :accepted,
          last_order_request_date: beginning_of_month
        )
      end

      let!(:pending_collaboration) do
        create(
          :user_collaboration,
          :monthly,
          :pending,
          last_order_request_date: beginning_of_month - 1.day
        )
      end

      let!(:rejected_collaborations) do
        create(
          :user_collaboration,
          :monthly,
          :rejected,
          last_order_request_date: beginning_of_month - 1.day
        )
      end

      it "Contains only collaborations that need to be renewed" do
        expect(subject).to eq([old_collaboration])
      end
    end
  end
end
