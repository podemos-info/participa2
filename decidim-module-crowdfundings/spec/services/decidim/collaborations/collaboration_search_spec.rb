# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Collaborations
    describe CollaborationSearch do
      let(:component) { create :collaboration_component, :participatory_process }

      describe "results" do
        subject do
          described_class.new(
            search_text: search_text,
            component: component,
            organization: component.organization
          ).results
        end

        let(:search_text) { nil }

        describe "when the filter includes search_text" do
          let(:search_text) { "dog" }

          it "returns the initiatives containing the search in the title or the description" do
            create_list(:collaboration, 3, component: component)
            create(:collaboration, title: { 'en': "A dog" }, component: component)
            create(:collaboration, description: { 'en': "There is a dog in the office" }, component: component)

            expect(subject.size).to eq(2)
          end
        end
      end
    end
  end
end
