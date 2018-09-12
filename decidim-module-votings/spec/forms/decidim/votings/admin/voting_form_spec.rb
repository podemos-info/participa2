# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe VotingForm do
        subject(:form) { described_class.from_params(attributes).with_context(context) }

        let(:organization) { create(:organization) }
        let(:participatory_process) do
          create :participatory_process, organization: organization
        end
        let(:step) do
          create(:participatory_process_step, participatory_process: participatory_process)
        end

        let(:context) do
          {
            current_organization: organization,
            current_participatory_space: participatory_process
          }
        end

        let(:title) { Decidim::Faker::Localized.sentence(3) }
        let(:description) { Decidim::Faker::Localized.sentence(3) }
        let(:image) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
        let(:start_date) { (Time.current + 1.day) }
        let(:end_date) { (Time.current + 2.days) }
        let(:scope) { create :scope, organization: organization }
        let(:scope_id) { scope.id }
        let(:importance) { ::Faker::Number.number(2).to_i }
        let(:simulation_code) { ::Faker::Number.number(2).to_i }
        let(:voting_system) { "nVotes" }
        let(:voting_domain_name) { "test.org" }
        let(:voting_identifier) { "identifier" }
        let(:shared_key) { "SHARED_KEY" }

        let(:attributes) do
          {
            title: title,
            description: description,
            image: image,
            start_date: start_date,
            end_date: end_date,
            decidim_scope_id: scope_id,
            importance: importance,
            simulation_code: simulation_code,
            voting_system: voting_system,
            voting_domain_name: voting_domain_name,
            voting_identifier: voting_identifier,
            shared_key: shared_key
          }
        end

        it { is_expected.to be_valid }

        context "when title is missing" do
          let(:title) { { en: nil } }

          it { is_expected.not_to be_valid }
        end

        context "when description is missing" do
          let(:description) { { en: nil } }

          it { is_expected.not_to be_valid }
        end

        describe "scope" do
          subject { form.scope }

          context "when the scope exists" do
            it { is_expected.to be_kind_of(Decidim::Scope) }
          end

          context "when the scope does not exist" do
            let(:scope_id) { scope.id + 10 }

            it { is_expected.to eq(nil) }
          end

          context "when the scope is from another organization" do
            let(:scope_id) { create(:scope).id }

            it { is_expected.to eq(nil) }
          end

          context "when the participatory space has a scope" do
            let(:parent_scope) { create(:scope, organization: organization) }
            let(:participatory_process) { create(:participatory_process, organization: organization, scope: parent_scope) }
            let(:scope) { create(:scope, organization: organization, parent: parent_scope) }

            context "when the scope is descendant from participatory space scope" do
              it { is_expected.to eq(scope) }
            end

            context "when the scope is not descendant from participatory space scope" do
              let(:scope) { create(:scope, organization: organization) }

              it { is_expected.to eq(scope) }

              it "makes the form invalid" do
                expect(form).to be_invalid
              end
            end
          end
        end

        context "when start_date is after end_time" do
          let(:start_date) { end_date + 3.days }

          it { is_expected.not_to be_valid }
        end

        context "when end_time is before start_time" do
          let(:end_date) { start_date - 3.days }

          it { is_expected.not_to be_valid }
        end

        context "with start_date" do
          context "when it's blank" do
            let(:start_date) { "" }

            it { is_expected.not_to be_valid }
          end

          context "when it is inside step bounds" do
            let(:start_date) { step.end_date - 1.day }
            let(:end_date) { step.end_date }

            it { is_expected.to be_valid }
          end

          context "when it is outside step bounds" do
            let(:start_date) { (step.start_date - 1.day) }

            it { is_expected.not_to be_valid }
          end
        end

        context "with end_date" do
          context "when it's blank" do
            let(:end_date) { "" }

            it { is_expected.not_to be_valid }
          end

          context "when it is inside step bounds" do
            let(:start_date) { step.start_date }
            let(:end_date) { step.end_date - 1.day }

            it { is_expected.to be_valid }
          end

          context "when it is outside step bounds" do
            let(:end_date) { step.end_date + 1.day }

            it { is_expected.not_to be_valid }
          end
        end

        context "with importance" do
          context "when it's blank" do
            let(:importance) { "" }

            it { is_expected.not_to be_valid }
          end

          context "when it is an integer" do
            let(:importance) { "7" }

            it { is_expected.to be_valid }
          end

          context "when it is not an integer" do
            let(:importance) { "nonumber" }

            it { is_expected.not_to be_valid }
          end
        end

        context "with simulation_code" do
          context "when it's blank" do
            let(:simulation_code) { "" }

            it { is_expected.not_to be_valid }
          end

          context "when it is an integer" do
            let(:simulation_code) { "7" }

            it { is_expected.to be_valid }
          end

          context "when it is not an integer" do
            let(:simulation_code) { "nonumber" }

            it { is_expected.not_to be_valid }
          end
        end
      end
    end
  end
end
