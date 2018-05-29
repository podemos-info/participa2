# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Votings
    module Admin
      describe ElectoralDistrictForm do
        subject { described_class.from_params(attributes) }

        let(:organization) { create(:organization) }
        let(:scope) { create(:scope, organization: organization) }
        let(:scope_id) { scope.id }

        let(:voting_identifier) { "identifier" }

        let(:attributes) do
          {
            decidim_scope_id: scope_id,
            voting_identifier: voting_identifier
          }
        end

        it { is_expected.to be_valid }

        context "when the scope does not exist" do
          let(:scope_id) { scope.id + 10 }

          it { is_expected.not_to be_valid }
        end

        context "when the scope is missing" do
          let(:scope_id) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when voting identifier is nil" do
          let(:voting_identifier) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when voting identifier is blank" do
          let(:voting_identifier) { "" }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
