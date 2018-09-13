# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe Campaign do
      subject { campaign }

      let(:campaign) { create :campaign }

      it { is_expected.to be_valid }

      context "without a component" do
        let(:campaign) { build :campaign, component: nil }

        it { is_expected.not_to be_valid }
      end

      describe "accepts_contributions?" do
        let(:active_until) { nil }
        let(:target_amount) { 10_000 }
        let(:total_collected) { 0 }
        let(:campaign) do
          build :campaign,
                target_amount: target_amount,
                active_until: active_until
        end

        before do
          stub_orders_total(total_collected)
        end

        context "when the contributing period has finished" do
          let(:active_until) { Time.zone.now - 1.day }

          it "returns false" do
            expect(campaign).not_to be_accepts_contributions
          end
        end

        context "when the target amount has been satisfied" do
          let(:total_collected) { target_amount + 1 }

          it "returns true" do
            expect(campaign).to be_accepts_contributions
          end
        end
      end

      describe "recurrent_support_allowed?" do
        context "with assemblies" do
          let(:campaign) { create :campaign, :assembly, target_amount: target_amount }
          let(:target_amount) { nil }

          it "accept recurrent supports" do
            expect(subject).to be_recurrent_support_allowed
          end
        end

        context "with participatory processes" do
          let(:campaign) { create :campaign }

          it "don't accept recurrent supports" do
            expect(subject).not_to be_recurrent_support_allowed
          end
        end

        context "with a target amount" do
          let(:target_amount) { 1000 }

          it "don't accept recurrent supports" do
            expect(subject).not_to be_recurrent_support_allowed
          end
        end
      end
    end
  end
end
