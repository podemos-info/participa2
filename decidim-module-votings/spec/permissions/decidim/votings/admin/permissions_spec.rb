# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { create(:user, organization: voting_component.organization) }
  let(:permission_action) { Decidim::PermissionAction.new(action) }
  let(:voting) { create(:voting) }
  let(:voting_component) { voting.component }
  let(:remote_authorization_url) { "http://example.org/authorizations" }
  let(:component_settings) { double(remote_authorization_url: remote_authorization_url) }
  let(:current_settings) { {} }
  let(:context) do
    {
      current_component: voting_component,
      current_settings: current_settings,
      component_settings: component_settings,
      **extra_context
    }
  end
  let(:extra_context) do
    {
      voting: voting
    }
  end

  context "when scope is not admin" do
    let(:action) do
      { scope: :foo, action: :create, subject: :voting }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a voting" do
    let(:action) do
      { scope: :admin, action: :create, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when creating a voting" do
    let(:extra_context) { {} }
    let(:action) do
      { scope: :admin, action: :create, subject: :voting }
    end

    it { is_expected.to eq true }
  end

  context "when updating a voting" do
    let(:action) do
      { scope: :admin, action: :update, subject: :voting }
    end

    it { is_expected.to eq true }
  end

  context "when destroying a voting" do
    let(:action) do
      { scope: :admin, action: :destroy, subject: :voting }
    end

    it { is_expected.to eq true }
  end
end
