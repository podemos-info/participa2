# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe UpdateContributionState do
      subject { described_class.new(contribution, target_state) }

      let(:contribution) do
        create(
          :contribution,
          :annual,
          :accepted
        )
      end

      let(:target_state) { "paused" }

      context "when successfull call" do
        it "is valid" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "updates the contribution state" do
          subject.call
          contribution.reload
          expect(contribution).to be_paused
        end
      end

      context "when update failed" do
        let(:target_state) { "invalid state" }

        it "is invalid" do
          expect { subject.call }.to broadcast(:ko)
        end
      end
    end
  end
end
