# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Collaborations
    describe UserRecurrentCampaignCollaborations do
      let(:collaboration) { create(:collaboration) }
      let(:user) { create(:user) }
      let(:subject) { described_class.new(user, collaboration).query }

      describe "Recurrent collaborations for the user" do
        let(:user_collaboration) do
          create(:user_collaboration,
                 frequency,
                 :accepted,
                 user: user,
                 collaboration: collaboration)
        end

        describe "monthly collaborations" do
          let(:frequency) { :monthly }

          it "are included" do
            expect(subject).to eq([user_collaboration])
          end
        end

        describe "quarterly collaborations" do
          let(:frequency) { :quarterly }

          it "are included" do
            expect(subject).to eq([user_collaboration])
          end
        end

        describe "annual collaborations" do
          let(:frequency) { :annual }

          it "are included" do
            expect(subject).to eq([user_collaboration])
          end
        end

        describe "punctual collaborations" do
          let(:frequency) { :punctual }

          it "are not included" do
            expect(subject).not_to eq([user_collaboration])
          end
        end
      end

      describe "Other users collaborations" do
        let(:monthly_user_collaboration) do
          create(:user_collaboration, :monthly, :accepted, collaboration: collaboration)
        end

        let(:quarterly_user_collaboration) do
          create(:user_collaboration, :quarterly, :accepted, collaboration: collaboration)
        end

        let(:annual_user_collaboration) do
          create(:user_collaboration, :annual, :accepted, collaboration: collaboration)
        end

        let(:punctual_user_collaboration) do
          create(:user_collaboration, :punctual, :accepted, collaboration: collaboration)
        end

        it "are not included" do
          expect(subject).not_to include(monthly_user_collaboration)
          expect(subject).not_to include(quarterly_user_collaboration)
          expect(subject).not_to include(annual_user_collaboration)
          expect(subject).not_to include(punctual_user_collaboration)
        end
      end
    end
  end
end
