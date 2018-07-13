# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe RecurrentContributions do
      let(:campaign) { create(:campaign) }
      let(:organization) { campaign.organization }
      let(:user) { create(:user, organization: organization) }
      let(:subject) { described_class.for_user(user) }

      describe "Recurrent contributions for the user" do
        let!(:monthly_contribution) do
          create(
            :contribution,
            :monthly,
            :accepted,
            user: user,
            campaign: campaign
          )
        end

        let!(:quarterly_contribution) do
          create(
            :contribution,
            :quarterly,
            :accepted,
            user: user,
            campaign: campaign
          )
        end

        let!(:annual_contribution) do
          create(
            :contribution,
            :annual,
            :accepted,
            user: user,
            campaign: campaign
          )
        end

        let!(:punctual_contribution) do
          create(
            :contribution,
            :punctual,
            :accepted,
            user: user,
            campaign: campaign
          )
        end

        let!(:others_monthly_contribution) do
          create(
            :contribution,
            :monthly,
            :accepted,
            campaign: campaign
          )
        end

        let!(:others_quarterly_contribution) do
          create(
            :contribution,
            :quarterly,
            :accepted,
            campaign: campaign
          )
        end

        let!(:others_annual_contribution) do
          create(
            :contribution,
            :annual,
            :accepted,
            campaign: campaign
          )
        end

        let!(:others_punctual_contribution) do
          create(
            :contribution,
            :punctual,
            :accepted,
            campaign: campaign
          )
        end

        it "includes only contributions by the user passed as parameter" do
          expect(subject).to contain_exactly(
            monthly_contribution,
            quarterly_contribution,
            annual_contribution
          )
        end
      end
    end
  end
end
