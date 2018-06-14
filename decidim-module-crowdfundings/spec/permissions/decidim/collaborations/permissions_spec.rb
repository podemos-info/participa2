# frozen_string_literal: true

require "spec_helper"

describe Decidim::Collaborations::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  before { stub_totals_request(user_annual_accumulated) }

  let(:user) { create(:user, organization: component.organization) }
  let(:user_annual_accumulated) { 0 }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:collaboration) { create(:collaboration, component: component) }
  let(:collaborations_allowed) { true }
  let(:component) { create(:collaboration_component, :assembly) }
  let(:component_settings) { {} }
  let(:current_settings) { double(collaborations_allowed?: collaborations_allowed) }
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
      collaboration: collaboration
    }
  end

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :create, subject: :collaboration }
    end

    it_behaves_like "delegates permissions to", Decidim::Collaborations::Admin::Permissions
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :support, subject: :collaboration }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a collaboration" do
    let(:action) do
      { scope: :public, action: :support, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  describe "support collaboration" do
    let(:action) do
      { scope: :public, action: :support, subject: :collaboration }
    end

    it { is_expected.to eq true }

    context "when collaborations are not allowed" do
      let(:collaborations_allowed) { false }

      it { is_expected.to eq false }
    end

    context "when collaboration does not accept supports" do
      let(:collaboration) { create(:collaboration, active_until: Time.zone.now - 1.day) }

      it { is_expected.to eq false }
    end

    context "when user is in the limit of annual maximum" do
      let(:user_annual_accumulated) { Decidim::Collaborations.maximum_annual_collaboration }

      it { is_expected.to eq false }
    end
  end

  describe "support recurrently" do
    let(:action) do
      { scope: :public, action: :support_recurrently, subject: :collaboration }
    end

    it { is_expected.to eq true }

    context "when user already has a recurrent support" do
      let!(:user_collaboration) { create(:user_collaboration, :monthly, :accepted, collaboration: collaboration, user: user) }

      it { is_expected.to eq false }
    end

    context "when component is not an assembly" do
      let(:component) { create(:collaboration_component, :participatory_process) }

      it { is_expected.to eq false }
    end
  end

  describe "user collaboration" do
    let(:user_collaboration) { create(:user_collaboration, frequency, state, collaboration: collaboration, user: owner) }
    let(:frequency) { :monthly }
    let(:owner) { user }

    let(:extra_context) do
      {
        user_collaboration: user_collaboration
      }
    end

    context "when updating" do
      let(:action) do
        { scope: :public, action: :update, subject: :user_collaboration }
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
        let(:owner) { create(:user, organization: collaboration.organization) }

        it { is_expected.to eq false }
      end
    end

    context "when resuming" do
      let(:action) do
        { scope: :public, action: :resume, subject: :user_collaboration }
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
        let(:owner) { create(:user, organization: collaboration.organization) }

        it { is_expected.to eq false }
      end
    end
  end
end
