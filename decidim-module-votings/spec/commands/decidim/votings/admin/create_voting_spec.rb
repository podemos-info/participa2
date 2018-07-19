# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe CreateVoting do
        subject { described_class.new(form) }

        let(:organization) { create(:organization) }
        let(:participatory_process) { create :participatory_process, organization: organization }
        let(:current_component) { create :voting_component, participatory_space: participatory_process }

        let(:context) do
          {
            current_organization: organization,
            current_component: current_component
          }
        end

        let(:title) { Decidim::Faker::Localized.sentence(3) }
        let(:description) { Decidim::Faker::Localized.sentence(3) }
        let(:image) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
        let(:start_date) { (Time.zone.today + 1.day).strftime("%Y-%m-%d") }
        let(:end_date) { (Time.zone.today + 5.days).strftime("%Y-%m-%d") }
        let(:scope) { create :scope, organization: organization }
        let(:scope_id) { scope.id }
        let(:importance) { ::Faker::Number.number(2).to_i }
        let(:simulation_code) { ::Faker::Number.number(1).to_i }
        let(:voting_system) { "nVotes" }
        let(:voting_domain_name) { "test.org" }
        let(:voting_identifier) { "identifier" }
        let(:shared_key) { "SHARED_KEY" }

        let(:child_scope) { create(:scope, parent: scope) }

        let(:electoral_districts) do
          [
            double(
              ElectoralDistrictForm,
              voting_identifier: "NEW",
              scope: child_scope
            )
          ]
        end

        let(:form) do
          double(
            invalid?: invalid,
            title: title,
            description: description,
            image: image,
            start_date: start_date,
            end_date: end_date,
            scope: scope,
            importance: importance,
            simulation_code: simulation_code,
            voting_system: voting_system,
            voting_domain_name: voting_domain_name,
            current_component: current_component,
            voting_identifier: voting_identifier,
            shared_key: shared_key,
            electoral_districts: electoral_districts
          )
        end

        let(:invalid) { false }

        context "when the form is not valid" do
          let(:invalid) { true }

          it "is not valid" do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context "when everything is ok" do
          let(:voting) { Decidim::Votings::Voting.last }

          it "creates the voting" do
            expect { subject.call }.to change { Decidim::Votings::Voting.count }.by(1)
          end

          it "sets the component" do
            subject.call

            expect(voting.component).to eq current_component
          end

          it "sets the electoral districts" do
            subject.call

            expect(voting.electoral_districts.count).to eq(1)
            expect(voting.electoral_districts.first.voting_identifier).to eq("NEW")
            expect(voting.electoral_districts.first.scope).to eq(child_scope)
          end

          it "sets all attributes received from the form" do
            subject.call

            expect(voting.title).to eq title
            expect(voting.description).to eq description
            expect(voting.image.path.split("/").last).to eq "city.jpeg"
            expect(voting.start_date.strftime("%Y-%m-%d")).to eq start_date
            expect(voting.end_date.strftime("%Y-%m-%d")).to eq end_date
            expect(voting.decidim_scope_id).to eq scope_id
            expect(voting.importance).to eq importance
            expect(voting.simulation_code).to eq simulation_code
            expect(voting.voting_system).to eq voting_system
            expect(voting.voting_domain_name).to eq voting_domain_name
          end
        end
      end
    end
  end
end
