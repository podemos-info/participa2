# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Collaborations
    describe UnconfirmedCollaborations do
      let(:subject) { described_class.new.query }

      let!(:pending_collaboration) do
        create(
          :user_collaboration,
          :punctual,
          :pending
        )
      end

      let!(:accepted_collaboration) do
        create(
          :user_collaboration,
          :punctual,
          :accepted
        )
      end

      let!(:rejected_collaboration) do
        create(
          :user_collaboration,
          :rejected,
          :punctual
        )
      end

      it "contains only pending collaborations" do
        expect(subject).to eq([pending_collaboration])
      end
    end
  end
end
