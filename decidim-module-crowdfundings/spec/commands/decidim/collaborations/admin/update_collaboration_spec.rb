# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Collaborations
    module Admin
      describe UpdateCollaboration do
        subject { described_class.new(form, collaboration) }

        let(:organization) { create(:organization) }
        let(:participatory_process) do
          create :participatory_process, organization: organization
        end
        let(:current_component) do
          create :collaboration_component,
                 participatory_space: participatory_process
        end

        let(:context) do
          {
            current_organization: organization,
            current_component: current_component
          }
        end

        let(:collaboration) { create(:collaboration, component: current_component) }

        let(:title) { Decidim::Faker::Localized.sentence(3) }
        let(:description) { Decidim::Faker::Localized.sentence(3) }
        let(:terms_and_conditions) { Decidim::Faker::Localized.paragraph(5) }
        let(:default_amount) { ::Faker::Number.number(2).to_i }
        let(:minimum_custom_amount) { ::Faker::Number.number(3).to_i }
        let(:target_amount) { ::Faker::Number.number(5).to_i }
        let(:active_until) { (Time.zone.today + 60.days).strftime("%Y-%m-%d") }
        let(:amounts) { "5,10,20,50" }
        let(:form) do
          double(
            invalid?: invalid,
            title: title,
            description: description,
            terms_and_conditions: terms_and_conditions,
            default_amount: default_amount,
            minimum_custom_amount: minimum_custom_amount,
            target_amount: target_amount,
            active_until: active_until,
            current_component: current_component,
            amounts: amounts
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
          let(:updated_collaboration) do
            Decidim::Collaborations::Collaboration.last
          end

          it "sets all attributes received from the form" do
            subject.call
            expect(updated_collaboration.title).to eq title
            expect(updated_collaboration.description).to eq description
            expect(updated_collaboration.terms_and_conditions).to eq terms_and_conditions
            expect(updated_collaboration.default_amount).to eq default_amount
            expect(updated_collaboration.minimum_custom_amount).to eq minimum_custom_amount
            expect(updated_collaboration.target_amount).to eq target_amount
            expect(updated_collaboration.active_until.strftime("%Y-%m-%d")).to eq active_until
            expect(updated_collaboration.amounts).to eq(amounts.split(",").map(&:to_i))
          end
        end
      end
    end
  end
end
