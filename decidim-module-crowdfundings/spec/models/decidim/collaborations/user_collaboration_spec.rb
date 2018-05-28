# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Collaborations
    describe UserCollaboration do
      subject { user_collaboration }

      let(:user_collaboration) do
        create :user_collaboration, :accepted, :punctual
      end

      it { is_expected.to be_valid }

      context "without a user" do
        let(:user_collaboration) do
          build :user_collaboration, :accepted, :punctual, user: nil
        end

        it { is_expected.not_to be_valid }
      end

      context "without a collaboration" do
        let(:user_collaboration) do
          build :user_collaboration,
                :accepted,
                :punctual,
                collaboration: nil,
                user: create(:user)
        end

        it { is_expected.not_to be_valid }
      end

      context "without state" do
        let(:user_collaboration) do
          build :user_collaboration, :punctual, state: nil
        end

        it { is_expected.not_to be_valid }
      end

      describe "amount" do
        context "without value" do
          let(:user_collaboration) do
            build :user_collaboration, :accepted, :punctual, amount: nil
          end

          it { is_expected.not_to be_valid }
        end

        context "with zero value" do
          let(:user_collaboration) do
            build :user_collaboration, :accepted, :punctual, amount: 0
          end

          it { is_expected.not_to be_valid }
        end

        context "with negative value" do
          let(:user_collaboration) do
            build :user_collaboration, :accepted, :punctual, amount: -1
          end

          it { is_expected.not_to be_valid }
        end
      end

      context "without frequency" do
        let(:user_collaboration) do
          build :user_collaboration, :accepted, frequency: nil
        end

        it { is_expected.not_to be_valid }
      end
    end
  end
end
