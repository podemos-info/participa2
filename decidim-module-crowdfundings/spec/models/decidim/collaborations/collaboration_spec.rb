# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Collaborations
    describe Collaboration do
      subject { collaboration }

      let(:collaboration) { create :collaboration }

      it { is_expected.to be_valid }

      context "without a component" do
        let(:collaboration) { build :collaboration, component: nil }

        it { is_expected.not_to be_valid }
      end

      describe "accepts_supports?" do
        let(:active_until) { nil }
        let(:target_amount) { 10_000 }
        let(:total_collected) { 0 }
        let(:collaboration) do
          build :collaboration,
                target_amount: target_amount,
                active_until: active_until
        end

        before do
          stub_totals_request(total_collected)
        end

        context "when the collecting period has finished" do
          let(:active_until) { Time.zone.now - 1.day }

          it "returns false" do
            expect(collaboration).not_to be_accepts_supports
          end
        end

        context "when the target amount has been satisfied" do
          let(:total_collected) { target_amount + 1 }

          it "returns true" do
            expect(collaboration).to be_accepts_supports
          end
        end
      end

      describe "percentage" do
        context "when API is up" do
          before do
            stub_totals_request(collaboration.target_amount / 2)
          end

          it "percentage calculated from census response" do
            expect(collaboration.percentage).to eq(50)
          end
        end

        context "when API returns error" do
          before do
            stub_totals_request_error
          end

          it "returns nil" do
            expect(collaboration.percentage).to be_nil
          end
        end

        context "when API is down" do
          before do
            stub_totals_service_down
          end

          it "returns nil" do
            expect(collaboration.percentage).to be_nil
          end
        end
      end

      describe "user percentage" do
        let(:user) { create(:user, organization: collaboration.organization) }

        context "when API is up" do
          before do
            stub_totals_request(collaboration.target_amount / 2)
          end

          it "Percentage calculated from census response" do
            expect(collaboration.user_percentage(user)).to eq(50)
          end
        end

        context "when API returns error" do
          before do
            stub_totals_request_error
          end

          it "returns nil" do
            expect(collaboration.user_percentage(user)).to be_nil
          end
        end

        context "when API is down" do
          before do
            stub_totals_service_down
          end

          it "returns nil" do
            expect(collaboration.user_percentage(user)).to be_nil
          end
        end
      end

      describe "user_total_collected" do
        let(:user) { create(:user, organization: collaboration.organization) }
        let(:amount) { collaboration.target_amount / 2 }

        context "when API is up" do
          before do
            stub_totals_request(amount)
          end

          it "Value is retrieved from census API" do
            expect(collaboration.user_total_collected(user)).to eq(amount)
          end
        end

        context "when API returns error" do
          before do
            stub_totals_request_error
          end

          it "returns nil" do
            expect(collaboration.user_total_collected(user)).to be_nil
          end
        end

        context "when API is down" do
          before do
            stub_totals_service_down
          end

          it "returns nil" do
            expect(collaboration.user_total_collected(user)).to be_nil
          end
        end
      end

      describe "recurrent_support_allowed?" do
        context "with assemblies" do
          let(:collaboration) { create :collaboration, :assembly }

          it "accept recurrent supports" do
            expect(subject).to be_recurrent_support_allowed
          end
        end

        context "with participatory processes" do
          let(:collaboration) { create :collaboration }

          it "don't accept recurrent supports" do
            expect(subject).not_to be_recurrent_support_allowed
          end
        end
      end
    end
  end
end
