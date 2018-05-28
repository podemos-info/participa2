# frozen_string_literal: true

require "spec_helper"
require "cancan/matchers"

describe Decidim::Collaborations::Abilities::CurrentUserAbility do
  subject { described_class.new(user, current_settings: current_settings) }

  let(:current_settings) { {} }
  let(:user_annual_accumulated) { 0 }
  let(:collaborations_allowed) { true }
  let(:collaboration) { create(:collaboration) }
  let(:user) { create(:user, organization: collaboration.component.organization) }

  before do
    stub_totals_request(user_annual_accumulated)
    expect(current_settings).to receive(:collaborations_allowed?)
      .at_most(:once)
      .and_return(collaborations_allowed)
  end

  describe "support collaboration" do
    context "when collaboration allowed" do
      let(:collaborations_allowed) { true }

      it "let the user support when collaboration accepts supports" do
        expect(collaboration).to receive(:accepts_supports?).and_return(true)
        expect(subject).to be_able_to(:support, collaboration)
      end

      it "Do not let the user support when collaboration does not accept supports" do
        expect(collaboration).to receive(:accepts_supports?).and_return(false)
        expect(subject).not_to be_able_to(:support, collaboration)
      end
    end

    context "when collaboration not allowed" do
      let(:collaborations_allowed) { false }

      it "do not let the user support when collaboration accepts supports" do
        expect(collaboration).to receive(:accepts_supports?).and_return(true)
        expect(subject).not_to be_able_to(:support, collaboration)
      end

      it "Do not let the user support when collaboration does not accept supports" do
        expect(collaboration).to receive(:accepts_supports?).and_return(false)
        expect(subject).not_to be_able_to(:support, collaboration)
      end
    end

    describe "Maximum annual per user validation" do
      context "when user is in the limit" do
        let(:user_annual_accumulated) { Decidim::Collaborations.maximum_annual_collaboration }

        it "User is not allowed to support" do
          expect(subject).not_to be_able_to(:support, collaboration)
        end
      end

      context "when user is under the limit" do
        let(:user_annual_accumulated) { 0 }

        it "User is allowed to support" do
          expect(subject).to be_able_to(:support, collaboration)
        end
      end
    end
  end

  describe "support_recurrently" do
    context "when first user recurrent support" do
      before do
        allow(collaboration).to receive(:recurrent_support_allowed?).and_return(true)
      end

      it "User can do a recurrent support" do
        expect(subject).to be_able_to(:support_recurrently, collaboration)
      end
    end

    context "when user already has a recurrent support" do
      let!(:user_collaboration) do
        create(:user_collaboration, :monthly, :accepted, collaboration: collaboration)
      end

      it "User can not do a recurrent support" do
        expect(subject).not_to be_able_to(:support_recurrently, collaboration)
      end
    end
  end

  describe "user collaboration" do
    let(:user_collaboration) do
      create(:user_collaboration,
             :punctual,
             state,
             collaboration: collaboration,
             user: owner)
    end

    describe "update user collaboration" do
      let(:state) { :accepted }

      context "with user collaboration owner" do
        let(:owner) { user }

        it "is allowed" do
          expect(subject).to be_able_to(:update, user_collaboration)
        end

        context "when state is not accepted" do
          let(:state) { :paused }

          it "is not allowed" do
            expect(subject).not_to be_able_to(:update, user_collaboration)
          end
        end
      end

      context "with other users" do
        let(:owner) { create(:user, organization: collaboration.organization) }

        it "do not allowed" do
          expect(subject).not_to be_able_to(:update, user_collaboration)
        end
      end
    end

    describe "resume user collaboration" do
      let(:state) { :paused }

      context "with user collaboration owner" do
        let(:owner) { user }

        it "is allowed" do
          expect(subject).to be_able_to(:resume, user_collaboration)
        end

        context "when state is not paused" do
          let(:state) { :accepted }

          it "is not allowed" do
            expect(subject).not_to be_able_to(:resume, user_collaboration)
          end
        end
      end

      context "with other users" do
        let(:owner) { create(:user, organization: collaboration.organization) }

        it "do not allowed" do
          expect(subject).not_to be_able_to(:resume, user_collaboration)
        end
      end
    end
  end
end
