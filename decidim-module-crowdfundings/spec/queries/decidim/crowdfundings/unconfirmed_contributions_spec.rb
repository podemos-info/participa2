# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe UnconfirmedContributions do
      let(:subject) { described_class.new.query }

      let!(:pending_contribution) do
        create(
          :contribution,
          :punctual,
          :pending
        )
      end

      let!(:accepted_contribution) do
        create(
          :contribution,
          :punctual,
          :accepted
        )
      end

      let!(:rejected_contribution) do
        create(
          :contribution,
          :rejected,
          :punctual
        )
      end

      it "contains only pending contributions" do
        expect(subject).to eq([pending_contribution])
      end
    end
  end
end
