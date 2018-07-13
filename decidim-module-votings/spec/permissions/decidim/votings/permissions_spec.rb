# frozen_string_literal: true

require "spec_helper"

describe Decidim::Votings::Permissions do
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
      voting: voting
    }
  end

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :create, subject: :voting }
    end

    it_behaves_like "delegates permissions to", Decidim::Votings::Admin::Permissions
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :voting }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a voting" do
    let(:action) do
      { scope: :public, action: :vote, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  describe "voting" do
    let(:action) do
      { scope: :public, action: :vote, subject: :voting }
    end

    context "when voting finished" do
      let(:voting) { create(:voting, start_date: Time.zone.now - 2.days, end_date: Time.zone.now - 1.day) }

      it { is_expected.to eq false }
    end
  end
end
