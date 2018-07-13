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

      describe "accepts_supports?" do
        let(:active_until) { nil }
        let(:target_amount) { 10_000 }
        let(:total_collected) { 0 }
        let(:campaign) do
          build :campaign,
                target_amount: target_amount,
                active_until: active_until
        end

        before do
          stub_totals_request(total_collected)
        end

        context "when the contributing period has finished" do
          let(:active_until) { Time.zone.now - 1.day }

          it "returns false" do
            expect(campaign).not_to be_accepts_supports
          end
        end

        context "when the target amount has been satisfied" do
          let(:total_collected) { target_amount + 1 }

          it "returns true" do
            expect(campaign).to be_accepts_supports
          end
        end
      end

      describe "percentage" do
        context "when API is up" do
          before do
            stub_totals_request(campaign.target_amount / 2)
          end

          it "percentage calculated from census response" do
            expect(campaign.percentage).to eq(50)
          end
        end

        context "when API returns error" do
          before do
            stub_totals_request_error
          end

          it "returns nil" do
            expect(campaign.percentage).to be_nil
          end
        end

        context "when API is down" do
          before do
            stub_totals_service_down
          end

          it "returns nil" do
            expect(campaign.percentage).to be_nil
          end
        end
      end

      describe "user percentage" do
        let(:user) { create(:user, organization: campaign.organization) }

        context "when API is up" do
          before do
            stub_totals_request(campaign.target_amount / 2)
          end

          it "Percentage calculated from census response" do
            expect(campaign.user_percentage(user)).to eq(50)
          end
        end

        context "when API returns error" do
          before do
            stub_totals_request_error
          end

          it "returns nil" do
            expect(campaign.user_percentage(user)).to be_nil
          end
        end

        context "when API is down" do
          before do
            stub_totals_service_down
          end

          it "returns nil" do
            expect(campaign.user_percentage(user)).to be_nil
          end
        end
      end

      describe "user_total_collected" do
        let(:user) { create(:user, organization: campaign.organization) }
        let(:amount) { campaign.target_amount / 2 }

        context "when API is up" do
          before do
            stub_totals_request(amount)
          end

          it "Value is retrieved from census API" do
            expect(campaign.user_total_collected(user)).to eq(amount)
          end
        end

        context "when API returns error" do
          before do
            stub_totals_request_error
          end

          it "returns nil" do
            expect(campaign.user_total_collected(user)).to be_nil
          end
        end

        context "when API is down" do
          before do
            stub_totals_service_down
          end

          it "returns nil" do
            expect(campaign.user_total_collected(user)).to be_nil
          end
        end
      end

      describe "recurrent_support_allowed?" do
        context "with assemblies" do
          let(:campaign) { create :campaign, :assembly }

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
      end
    end
  end
end
