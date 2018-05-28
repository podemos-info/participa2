# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Collaborations
    describe RecurrentCollaborations do
      let(:collaboration) { create(:collaboration) }
      let(:organization) { collaboration.organization }
      let(:user) { create(:user, organization: organization) }
      let(:subject) { described_class.for_user(user) }

      describe "Recurrent collaborations for the user" do
        let!(:monthly_collaboration) do
          create(
            :user_collaboration,
            :monthly,
            :accepted,
            user: user,
            collaboration: collaboration
          )
        end

        let!(:quarterly_collaboration) do
          create(
            :user_collaboration,
            :quarterly,
            :accepted,
            user: user,
            collaboration: collaboration
          )
        end

        let!(:annual_collaboration) do
          create(
            :user_collaboration,
            :annual,
            :accepted,
            user: user,
            collaboration: collaboration
          )
        end

        let!(:punctual_collaboration) do
          create(
            :user_collaboration,
            :punctual,
            :accepted,
            user: user,
            collaboration: collaboration
          )
        end

        let!(:others_monthly_collaboration) do
          create(
            :user_collaboration,
            :monthly,
            :accepted,
            collaboration: collaboration
          )
        end

        let!(:others_quarterly_collaboration) do
          create(
            :user_collaboration,
            :quarterly,
            :accepted,
            collaboration: collaboration
          )
        end

        let!(:others_annual_collaboration) do
          create(
            :user_collaboration,
            :annual,
            :accepted,
            collaboration: collaboration
          )
        end

        let!(:others_punctual_collaboration) do
          create(
            :user_collaboration,
            :punctual,
            :accepted,
            collaboration: collaboration
          )
        end

        it "includes only collaborations by the user passed as parameter" do
          expect(subject).to contain_exactly(
            monthly_collaboration,
            quarterly_collaboration,
            annual_collaboration
          )
        end
      end
    end
  end
end
