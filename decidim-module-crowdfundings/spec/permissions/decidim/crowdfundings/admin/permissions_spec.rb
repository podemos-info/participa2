# frozen_string_literal: true

require "spec_helper"

describe Decidim::Crowdfundings::Admin::Permissions do
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

  context "when scope is not admin" do
    let(:action) do
      { scope: :foo, action: :create, subject: :campaign }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a campaign" do
    let(:action) do
      { scope: :admin, action: :create, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when creating a campaign" do
    let(:extra_context) { {} }
    let(:action) do
      { scope: :admin, action: :create, subject: :campaign }
    end

    it { is_expected.to eq true }
  end

  context "when updating a campaign" do
    let(:action) do
      { scope: :admin, action: :update, subject: :campaign }
    end

    it { is_expected.to eq true }
  end

  context "when destroying a campaign" do
    let(:action) do
      { scope: :admin, action: :destroy, subject: :campaign }
    end

    it { is_expected.to eq true }
  end
end
