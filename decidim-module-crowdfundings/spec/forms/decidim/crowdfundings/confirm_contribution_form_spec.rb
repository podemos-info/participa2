# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe ConfirmContributionForm do
      subject { described_class.from_params(attributes).with_context(context) }

      let(:campaign) { create(:campaign) }
      let(:current_user) { create(:user, organization: campaign.organization) }

      let(:amount) { ::Faker::Number.number(4) }
      let(:frequency) { "punctual" }
      let(:payment_method_type) { "credit_card_external" }
      let(:payment_method_id) { nil }
      let(:iban) { nil }
      let(:accept_terms_and_conditions) { true }

      let(:attributes) do
        {
          amount: amount,
          frequency: frequency,
          payment_method_type: payment_method_type,
          payment_method_id: payment_method_id,
          iban: iban,
          accept_terms_and_conditions: true
        }
      end

      let(:context) do
        {
          current_organization: campaign.organization,
          current_component: campaign.component,
          campaign: campaign,
          current_user: current_user
        }
      end

      it { is_expected.to be_valid }

      before do
        stub_totals_request(0)
      end

      describe "direct_debit" do
        let(:payment_method_type) { "direct_debit" }

        it { is_expected.not_to be_credit_card_external }
        it { is_expected.not_to be_existing_payment_method }
        it { is_expected.to be_direct_debit }

        context "when iban is missing" do
          let(:iban) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when iban is invalid" do
          let(:iban) { "Abcd1234" }

          it { is_expected.not_to be_valid }
        end

        context "when iban is valid" do
          let(:iban) { "ES5463332518114045210672" }

          it { is_expected.to be_valid }
        end
      end

      context "when payment_method_id missing" do
        let(:payment_method_type) { "existing_payment_method" }
        let(:payment_method_id) { nil }

        it { is_expected.not_to be_credit_card_external }
        it { is_expected.to be_existing_payment_method }
        it { is_expected.not_to be_direct_debit }

        it { is_expected.not_to be_valid }
      end

      describe "Credit card external" do
        let(:payment_method_type) { "credit_card_external" }

        it { is_expected.to be_credit_card_external }
        it { is_expected.not_to be_existing_payment_method }
        it { is_expected.not_to be_direct_debit }
      end
    end
  end
end
