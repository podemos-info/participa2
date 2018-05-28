# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Collaborations
    describe UpdateUserCollaborationState do
      subject { described_class.new(user_collaboration, target_state) }

      let(:user_collaboration) do
        create(
          :user_collaboration,
          :annual,
          :accepted
        )
      end

      let(:target_state) { "paused" }

      context "when successfull call" do
        it "is valid" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "updates the user collaboration state" do
          subject.call
          user_collaboration.reload
          expect(user_collaboration).to be_paused
        end
      end

      context "when update failed" do
        let(:target_state) { "invalid state" }

        it "is invalid" do
          expect { subject.call }.to broadcast(:ko)
        end
      end
    end
  end
end
