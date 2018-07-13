# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    module Admin
      describe CampaignForm do
        subject { described_class.from_params(attributes).with_context(context) }

        let(:organization) { create(:organization) }
        let(:participatory_process) do
          create :participatory_process, organization: organization
        end
        let(:step) do
          create(:participatory_process_step, participatory_process: participatory_process)
        end
        let(:current_component) do
          create :crowdfundings_component, participatory_space: participatory_process
        end

        let(:context) do
          {
            current_organization: organization,
            current_component: current_component
          }
        end

        let(:title) { Decidim::Faker::Localized.sentence(3) }
        let(:description) { Decidim::Faker::Localized.sentence(3) }
        let(:terms_and_conditions) { Decidim::Faker::Localized.paragraph(5) }
        let(:default_amount) { ::Faker::Number.number(2) }
        let(:minimum_custom_amount) { ::Faker::Number.number(3) }
        let(:target_amount) { ::Faker::Number.number(5) }
        let(:amounts) { Decidim::Crowdfundings.selectable_amounts.join(", ") }
        let(:active_until) { step.end_date.strftime("%Y-%m-%d") }

        let(:attributes) do
          {
            title: title,
            description: description,
            terms_and_conditions: terms_and_conditions,
            default_amount: default_amount,
            minimum_custom_amount: minimum_custom_amount,
            target_amount: target_amount,
            amounts: amounts,
            active_until: active_until
          }
        end

        it { is_expected.to be_valid }

        describe "when title is missing" do
          let(:title) { { en: nil } }

          it { is_expected.not_to be_valid }
        end

        describe "when description is missing" do
          let(:description) { { en: nil } }

          it { is_expected.not_to be_valid }
        end

        describe "when terms and conditions is missing" do
          let(:terms_and_conditions) { { en: nil } }

          it { is_expected.not_to be_valid }
        end

        describe "default_amount" do
          context "when missing" do
            let(:default_amount) { nil }

            it { is_expected.not_to be_valid }
          end

          context "when less or equal than 0" do
            let(:default_amount) { 0 }

            it { is_expected.not_to be_valid }
          end
        end

        describe "minimum_custom_amount" do
          context "when is missing" do
            let(:minimum_custom_amount) { nil }

            it { is_expected.not_to be_valid }
          end

          context "when less or equal than 0" do
            let(:minimum_custom_amount) { 0 }

            it { is_expected.not_to be_valid }
          end
        end

        describe "target_amount" do
          context "when missing" do
            let(:target_amount) { nil }

            it { is_expected.to be_valid }
          end

          context "with less or equal than 0" do
            let(:target_amount) { 0 }

            it { is_expected.not_to be_valid }
          end
        end

        describe "amounts" do
          context "when missing" do
            let(:amounts) { nil }

            it { is_expected.not_to be_valid }
          end

          context "with invalid format" do
            let(:amounts) { "weird input" }

            it { is_expected.not_to be_valid }
          end
        end

        describe "active_until" do
          context "when blank" do
            let(:active_until) { "" }

            it { is_expected.to be_valid }
          end

          context "when inside step bounds" do
            let(:active_until) { (step.end_date - 1.day).strftime("%Y-%m-%d") }

            it { is_expected.to be_valid }
          end

          context "when outside step bounds" do
            let(:active_until) { (step.end_date + 1.day).strftime("%Y-%m-%d") }

            it { is_expected.not_to be_valid }
          end
        end
      end
    end
  end
end
