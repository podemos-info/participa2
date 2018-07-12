# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe Contribution do
      subject { contribution }

      let(:contribution) do
        create :contribution, :accepted, :punctual
      end

      it { is_expected.to be_valid }

      context "without a user" do
        let(:contribution) do
          build :contribution, :accepted, :punctual, user: nil
        end

        it { is_expected.not_to be_valid }
      end

      context "without a campaign" do
        let(:contribution) do
          build :contribution,
                :accepted,
                :punctual,
                campaign: nil,
                user: create(:user)
        end

        it { is_expected.not_to be_valid }
      end

      context "without state" do
        let(:contribution) do
          build :contribution, :punctual, state: nil
        end

        it { is_expected.not_to be_valid }
      end

      describe "amount" do
        context "without value" do
          let(:contribution) do
            build :contribution, :accepted, :punctual, amount: nil
          end

          it { is_expected.not_to be_valid }
        end

        context "with zero value" do
          let(:contribution) do
            build :contribution, :accepted, :punctual, amount: 0
          end

          it { is_expected.not_to be_valid }
        end

        context "with negative value" do
          let(:contribution) do
            build :contribution, :accepted, :punctual, amount: -1
          end

          it { is_expected.not_to be_valid }
        end
      end

      context "without frequency" do
        let(:contribution) do
          build :contribution, :accepted, frequency: nil
        end

        it { is_expected.not_to be_valid }
      end
    end
  end
end
