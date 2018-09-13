# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe ContributionForm do
      subject { described_class.from_params(attributes).with_context(context) }

      let(:campaign) { create(:campaign) }
      let(:payments_proxy) { create(:payments_proxy, organization: campaign.organization) }
      let(:current_user) { payments_proxy.user }

      let(:amount) { ::Faker::Number.number(4) }
      let(:frequency) { "punctual" }
      let(:payment_method_type) { "existing_payment_method" }
      let(:user_annual_accumulated) { 0 }
      let(:accept_terms_and_conditions) { true }
      let(:attributes) do
        {
          amount: amount,
          frequency: frequency,
          payment_method_type: payment_method_type
        }
      end

      let(:context) do
        {
          current_organization: campaign.organization,
          current_component: campaign.component,
          current_user: current_user,
          campaign: campaign,
          payments_proxy: payments_proxy
        }
      end

      before do
        stub_orders_total(user_annual_accumulated)
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
          let(:amount) { campaign.minimum_custom_amount - 1 }

          it { is_expected.not_to be_valid }
        end

        context "when over the maximum" do
          let(:user_annual_accumulated) { Decidim::Crowdfundings.maximum_annual_contribution_amount + 1 }

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
    end
  end
end
