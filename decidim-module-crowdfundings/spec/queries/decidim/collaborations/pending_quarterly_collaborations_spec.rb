# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Collaborations
    describe PendingQuarterlyCollaborations do
      let(:subject) { described_class.new.query }

      let(:beginning_of_month) { Time.zone.today.beginning_of_month }

      let!(:annual_collaboration) do
        create(
          :user_collaboration,
          :annual,
          :accepted,
          last_order_request_date: beginning_of_month - 11.months - 1.day
        )
      end

      let!(:old_collaboration) do
        create(
          :user_collaboration,
          :quarterly,
          :accepted,
          last_order_request_date: beginning_of_month - 2.months - 1.day
        )
      end

      let!(:recent_collaboration) do
        create(
          :user_collaboration,
          :quarterly,
          :accepted,
          last_order_request_date: beginning_of_month - 2.months
        )
      end

      let!(:pending_collaboration) do
        create(
          :user_collaboration,
          :quarterly,
          :pending,
          last_order_request_date: beginning_of_month - 2.months - 1.day
        )
      end

      let!(:rejected_collaboration) do
        create(
          :user_collaboration,
          :quarterly,
          :rejected,
          last_order_request_date: beginning_of_month - 2.months - 1.day
        )
      end

      it "Contains only collaborations that need to be renewed" do
        expect(subject).to eq([old_collaboration])
      end
    end
  end
end
