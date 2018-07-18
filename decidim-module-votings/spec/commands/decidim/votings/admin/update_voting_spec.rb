# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe UpdateVoting do
        subject { described_class.new(form, voting) }

        let(:organization) do
          create(:organization)
        end

        let(:participatory_process) do
          create(:participatory_process, organization: organization)
        end

        let(:current_component) do
          create(:voting_component, participatory_space: participatory_process)
        end

        let(:initial_shared_key) { "INITIAL" }
        let(:voting) { create(:voting, component: current_component, shared_key: initial_shared_key) }

        let(:title) { Decidim::Faker::Localized.sentence(3) }
        let(:description) { Decidim::Faker::Localized.sentence(3) }
        let(:image) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
        let(:start_date) { (Time.zone.today + 1.day).strftime("%Y-%m-%d") }
        let(:end_date) { (Time.zone.today + 5.days).strftime("%Y-%m-%d") }
        let(:scope) { create(:scope, organization: organization) }
        let(:scope_id) { scope.id }
        let(:importance) { ::Faker::Number.number(2).to_i }
        let(:simulation_code) { ::Faker::Number.number(1).to_i }
        let(:voting_system) { "nVotes" }
        let(:voting_domain_name) { "test.org" }
        let(:voting_identifier) { "identifier" }
        let(:change_shared_key) { true }
        let(:shared_key) { "SHARED_KEY" }
        let(:electoral_districts) { [] }

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
            voting_identifier: voting_identifier,
            change_shared_key: change_shared_key,
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
          let(:updated_voting) { Decidim::Votings::Voting.last }

          it "sets all attributes received from the form" do
            subject.call
            expect(updated_voting.title).to eq title
            expect(updated_voting.description).to eq description
            expect(updated_voting.image.path.split("/").last).to eq "city.jpeg"
            expect(updated_voting.start_date.strftime("%Y-%m-%d")).to eq start_date
            expect(updated_voting.end_date.strftime("%Y-%m-%d")).to eq end_date
            expect(updated_voting.decidim_scope_id).to eq scope_id
            expect(updated_voting.importance).to eq importance
            expect(updated_voting.simulation_code).to eq simulation_code
            expect(updated_voting.voting_system).to eq voting_system
            expect(updated_voting.voting_domain_name).to eq voting_domain_name
            expect(updated_voting.shared_key).to eq shared_key
          end
        end

        context "when electoral districts present" do
          let(:for_creation) { false }
          let(:for_update) { false }
          let(:for_removal) { false }

          let(:child_scope) { create(:scope, parent: scope) }
          let(:id) { nil }

          let(:electoral_districts) do
            [
              double(
                ElectoralDistrictForm,
                for_creation?: for_creation,
                for_update?: for_update,
                for_removal?: for_removal,
                id: id,
                voting_identifier: "NEW",
                scope: child_scope
              )
            ]
          end

          context "when marked to be created" do
            let(:for_creation) { true }

            it "creates an electoral district record in addition" do
              expect { subject.call }.to change(Decidim::Votings::ElectoralDistrict, :count).by(1)
            end
          end

          context "when marked to be updated" do
            let!(:electoral_district) do
              create(:electoral_district, voting: voting, voting_identifier: "OLD")
            end

            let(:for_update) { true }
            let(:id) { electoral_district.id }

            it "creates the voting but does not change the electoral district record count" do
              expect { subject.call }.not_to change(Decidim::Votings::ElectoralDistrict, :count)
            end

            it "updates the electoral district record" do
              subject.call

              expect(electoral_district.reload.voting_identifier).to eq("NEW")
            end
          end

          context "when marked to be deleted" do
            let!(:electoral_district) do
              create(:electoral_district, voting: voting)
            end

            let(:for_removal) { true }
            let(:id) { electoral_district.id }

            it "deletes an electoral district record" do
              expect { subject.call }.to change(Decidim::Votings::ElectoralDistrict, :count).by(-1)
            end

            it "deletes the right electoral district record" do
              subject.call

              expect { electoral_district.reload }.to raise_error(ActiveRecord::RecordNotFound)
            end
          end
        end

        context "when voting has votes" do
          let(:updated_voting) { Decidim::Votings::Voting.last }
          let!(:vote) { create(:vote, voting: voting) }

          it "does not change shared key" do
            subject.call
            expect(updated_voting.shared_key).to eq initial_shared_key
          end
        end

        context "when shared_key not selected to be changed" do
          let(:change_shared_key) { false }

          let(:updated_voting) { Decidim::Votings::Voting.last }

          it "sets all attributes received from the form except shared key" do
            subject.call

            expect(updated_voting.title).to eq title
            expect(updated_voting.description).to eq description
            expect(updated_voting.image.path.split("/").last).to eq "city.jpeg"
            expect(updated_voting.start_date.strftime("%Y-%m-%d")).to eq start_date
            expect(updated_voting.end_date.strftime("%Y-%m-%d")).to eq end_date
            expect(updated_voting.decidim_scope_id).to eq scope_id
            expect(updated_voting.importance).to eq importance
            expect(updated_voting.simulation_code).to eq simulation_code
            expect(updated_voting.voting_system).to eq voting_system
            expect(updated_voting.voting_domain_name).to eq voting_domain_name
            expect(updated_voting.shared_key).to eq initial_shared_key
          end
        end
      end
    end
  end
end
