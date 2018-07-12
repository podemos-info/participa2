# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe CampaignRecurrentContributions do
      let(:campaign) { create(:campaign) }
      let(:user) { create(:user) }
      let(:subject) { described_class.new(user, campaign).query }

      describe "Recurrent contributions for the user" do
        let(:contribution) do
          create(:contribution,
                 frequency,
                 :accepted,
                 user: user,
                 campaign: campaign)
        end

        describe "monthly collaborations" do
          let(:frequency) { :monthly }

          it "are included" do
            expect(subject).to eq([contribution])
          end
        end

        describe "quarterly collaborations" do
          let(:frequency) { :quarterly }

          it "are included" do
            expect(subject).to eq([contribution])
          end
        end

        describe "annual collaborations" do
          let(:frequency) { :annual }

          it "are included" do
            expect(subject).to eq([contribution])
          end
        end

        describe "punctual collaborations" do
          let(:frequency) { :punctual }

          it "are not included" do
            expect(subject).not_to eq([contribution])
          end
        end
      end

      describe "Other users contributions" do
        let(:monthly_contribution) do
          create(:contribution, :monthly, :accepted, campaign: campaign)
        end

        let(:quarterly_contribution) do
          create(:contribution, :quarterly, :accepted, campaign: campaign)
        end

        let(:annual_contribution) do
          create(:contribution, :annual, :accepted, campaign: campaign)
        end

        let(:punctual_contribution) do
          create(:contribution, :punctual, :accepted, campaign: campaign)
        end

        it "are not included" do
          expect(subject).not_to include(monthly_contribution)
          expect(subject).not_to include(quarterly_contribution)
          expect(subject).not_to include(annual_contribution)
          expect(subject).not_to include(punctual_contribution)
        end
      end
    end
  end
end
