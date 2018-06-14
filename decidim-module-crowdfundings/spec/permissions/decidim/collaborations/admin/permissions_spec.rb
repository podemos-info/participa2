# frozen_string_literal: true

require "spec_helper"

describe Decidim::Collaborations::Admin::Permissions do
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

  context "when scope is not admin" do
    let(:action) do
      { scope: :foo, action: :create, subject: :collaboration }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a collaboration" do
    let(:action) do
      { scope: :admin, action: :create, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when creating a collaboration" do
    let(:extra_context) { {} }
    let(:action) do
      { scope: :admin, action: :create, subject: :collaboration }
    end

    it { is_expected.to eq true }
  end

  context "when updating a collaboration" do
    let(:action) do
      { scope: :admin, action: :update, subject: :collaboration }
    end

    it { is_expected.to eq true }
  end

  context "when destroying a collaboration" do
    let(:action) do
      { scope: :admin, action: :destroy, subject: :collaboration }
    end

    it { is_expected.to eq true }
  end
end
