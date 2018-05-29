# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Collaborations
    describe UserCollaborationForm do
      subject { described_class.from_params(attributes).with_context(context) }

      let(:collaboration) { create(:collaboration) }

      let(:current_user) { create(:user, organization: collaboration.organization) }
      let(:amount) { ::Faker::Number.number(4) }
      let(:frequency) { "punctual" }
      let(:payment_method_type) { "existing_payment_method" }
      let(:user_annual_accumulated) { 0 }
      let(:over_18) { true }
      let(:accept_terms_and_conditions) { true }
      let(:attributes) do
        {
          amount: amount,
          frequency: frequency,
          payment_method_type: payment_method_type,
          over_18: over_18,
          accept_terms_and_conditions: accept_terms_and_conditions
        }
      end

      let(:context) do
        {
          current_organization: collaboration.organization,
          current_component: collaboration.component,
          current_user: current_user,
          collaboration: collaboration
        }
      end

      before do
        stub_totals_request(user_annual_accumulated)
      end

      it { is_expected.to be_valid }

      describe "amount" do
        context "when missing" do
          let(:amount) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when zero" do
          let(:amount) { 0 }

          it { is_expected.not_to be_valid }
        end

        context "when a negative number" do
          let(:amount) { -1 }

          it { is_expected.not_to be_valid }
        end

        context "when not an integer" do
          let(:amount) { 1.01 }

          it { is_expected.not_to be_valid }
        end

        context "when bellow the minimum valid" do
          let(:amount) { collaboration.minimum_custom_amount - 1 }

          it { is_expected.not_to be_valid }
        end

        context "when over the maximum" do
          let(:user_annual_accumulated) { Decidim::Collaborations.maximum_annual_collaboration }

          it { is_expected.not_to be_valid }
        end
      end

      context "when frequency is missing" do
        let(:frequency) { nil }

        it { is_expected.not_to be_valid }
      end

      context "with frequency is invalid" do
        let(:frequency) { "invalid value" }

        it { is_expected.not_to be_valid }
      end

      context "when payment method is missing" do
        let(:payment_method_type) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when over 18 is missing" do
        let(:over_18) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when accept_terms_and_conditions is missing" do
        let(:accept_terms_and_conditions) { nil }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
