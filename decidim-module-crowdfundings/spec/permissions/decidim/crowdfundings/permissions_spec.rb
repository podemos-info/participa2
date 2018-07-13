# frozen_string_literal: true

require "spec_helper"

describe Decidim::Crowdfundings::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  before { stub_totals_request(user_annual_accumulated) }

  let(:user) { create(:user, organization: component.organization) }
  let(:user_annual_accumulated) { 0 }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:campaign) { create(:campaign, component: component) }
  let(:contribution_allowed) { true }
  let(:component) { create(:crowdfundings_component, :assembly) }
  let(:component_settings) { {} }
  let(:current_settings) { double(contribution_allowed?: contribution_allowed) }
  let(:context) do
    {
      current_component: component,
      current_settings: current_settings,
      component_settings: component_settings,
      **extra_context
    }
  end
  let(:extra_context) do
    {
      campaign: campaign
    }
  end

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :create, subject: :campaign }
    end

    it_behaves_like "delegates permissions to", Decidim::Crowdfundings::Admin::Permissions
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :support, subject: :campaign }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a campaign" do
    let(:action) do
      { scope: :public, action: :support, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  describe "support campaign" do
    let(:action) do
      { scope: :public, action: :support, subject: :campaign }
    end

    it { is_expected.to eq true }

    context "when contribution is not allowed" do
      let(:contribution_allowed) { false }

      it { is_expected.to eq false }
    end

    context "when campaign does not accept supports" do
      let(:campaign) { create(:campaign, active_until: Time.zone.now - 1.day) }

      it { is_expected.to eq false }
    end

    context "when user is in the limit of annual maximum" do
      let(:user_annual_accumulated) { Decidim::Crowdfundings.maximum_annual_contribution_amount }

      it { is_expected.to eq false }
    end
  end

  describe "support recurrently" do
    let(:action) do
      { scope: :public, action: :support_recurrently, subject: :campaign }
    end

    it { is_expected.to eq true }

    context "when user already has a recurrent contribution" do
      let!(:contribution) { create(:contribution, :monthly, :accepted, campaign: campaign, user: user) }

      it { is_expected.to eq false }
    end

    context "when component is not an assembly" do
      let(:component) { create(:crowdfundings_component, :participatory_process) }

      it { is_expected.to eq false }
    end
  end

  describe "contribution" do
    let(:contribution) { create(:contribution, frequency, state, campaign: campaign, user: owner) }
    let(:frequency) { :monthly }
    let(:owner) { user }

    let(:extra_context) do
      {
        contribution: contribution
      }
    end

    context "when updating" do
      let(:action) do
        { scope: :public, action: :update, subject: :contribution }
      end
      let(:state) { :accepted }

      it { is_expected.to eq true }

      context "when is not recurrent" do
        let(:frequency) { :punctual }

        it { is_expected.to eq false }
      end

      context "when state is not accepted" do
        let(:state) { :paused }

        it { is_expected.to eq false }
      end

      context "when user is not owner" do
        let(:owner) { create(:user, organization: campaign.organization) }

        it { is_expected.to eq false }
      end
    end

    context "when resuming" do
      let(:action) do
        { scope: :public, action: :resume, subject: :contribution }
      end
      let(:state) { :paused }

      it { is_expected.to eq true }

      context "when is not recurrent" do
        let(:frequency) { :punctual }

        it { is_expected.to eq false }
      end

      context "when state is not paused" do
        let(:state) { :accepted }

        it { is_expected.to eq false }
      end

      context "when user is not owner" do
        let(:owner) { create(:user, organization: campaign.organization) }

        it { is_expected.to eq false }
      end
    end
  end
end
