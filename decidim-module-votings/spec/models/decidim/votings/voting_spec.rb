# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::Voting do
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization: organization) }
  let(:component) { create(:voting_component, participatory_space: participatory_space) }

  let!(:parent) { create(:scope, organization: organization) }
  let!(:main) { create(:scope, parent: parent) }
  let!(:child) { create(:scope, parent: main) }

  let!(:child_with_electoral_district) do
    scope = create(:scope, parent: main)

    voting.electoral_districts.create!(
      scope: scope,
      voting_identifier: "CWED"
    )

    scope
  end

  let!(:grandchild_with_electoral_district) do
    scope = create(:scope, parent: child)

    voting.electoral_districts.create!(
      scope: scope,
      voting_identifier: "GWED"
    )

    scope
  end

  let!(:grandchild_with_electoral_district_in_parent) do
    create(:scope, parent: child_with_electoral_district)
  end

  let!(:grandchild_without_electoral_district_in_parent) do
    create(:scope, parent: child)
  end

  let(:voting) { create(:voting, component: component, voting_identifier: "V", scope: main) }

  describe "#voting_identifier_for" do
    context "when given scope is the voting scope" do
      let(:resolved_identifier) { voting.voting_identifier_for(main) }

      it "gives the main voting identifier" do
        expect(resolved_identifier).to eq("V")
      end
    end

    context "when given scope is a first level descendant of the main scope" do
      context "and it has an electoral district set" do
        let(:resolved_identifier) do
          voting.voting_identifier_for(child_with_electoral_district)
        end

        it "gives the voting identifier of the electoral district" do
          expect(resolved_identifier).to eq("CWED")
        end
      end

      context "and it does not have an electoral district set" do
        let(:resolved_identifier) do
          voting.voting_identifier_for(child)
        end

        it "gives the main voting identifier" do
          expect(resolved_identifier).to eq("V")
        end
      end
    end

    context "when given scope is a second level descendant of the main scope" do
      context "and it has an electoral district set" do
        let(:resolved_identifier) do
          voting.voting_identifier_for(grandchild_with_electoral_district)
        end

        it "gives the voting identifier of the electoral district" do
          expect(resolved_identifier).to eq("GWED")
        end
      end

      context "and it does not have an electoral district set" do
        context "and its parent has it" do
          let(:resolved_identifier) do
            voting.voting_identifier_for(grandchild_with_electoral_district_in_parent)
          end

          it "gives the voting identifier of the parent's electoral district" do
            expect(resolved_identifier).to eq("CWED")
          end
        end

        context "and neither its parent" do
          let(:resolved_identifier) do
            voting.voting_identifier_for(grandchild_without_electoral_district_in_parent)
          end

          it "gives the main voting identifier" do
            expect(resolved_identifier).to eq("V")
          end
        end
      end
    end

    context "when given scope is not a child of the main scope" do
      let(:resolved_identifier) { voting.voting_identifier_for(parent) }

      it "returns nil" do
        expect(resolved_identifier).to be_nil
      end
    end
  end
end
