# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DestroyAccount, :vcr do
    subject(:command) { described_class.new(user, form).call }

    let(:user) { create(:user, :with_person, :confirmed, person_id: 5) }
    let(:person_proxy) { Decidim::CensusConnector::PersonProxy.for(user) }
    let!(:identity) { create(:identity, user: user) }
    let(:delete_reason) { "I want to delete my account" }

    let(:form) do
      Decidim::DeleteAccountForm.new(
        delete_reason: delete_reason
      ).with_context(
        person: person_proxy.person,
        person_proxy: person_proxy
      )
    end

    let(:valid) { true }

    it "broadcasts ok" do
      expect { subject }.to broadcast(:ok)
    end

    it "stores the deleted_at and delete_reason to the user" do
      subject
      expect(user.reload.delete_reason).to eq(delete_reason)
      expect(user.reload.deleted_at).not_to be_nil
    end

    it "set name, nickname and email to blank string" do
      subject
      expect(user.reload.name).to eq("")
      expect(user.reload.nickname).to eq("")
      expect(user.reload.email).to eq("")
    end

    it "destroys the current user avatar" do
      subject
      expect(user.reload.avatar).not_to be_present
    end

    it "deletes user's identities" do
      expect { subject } .to change(Identity, :count).by(-1)
    end

    it "deletes user group memberships" do
      user_group = create(:user_group)
      create(:user_group_membership, user_group: user_group, user: user)

      expect { subject } .to change(UserGroupMembership, :count).by(-1)
    end

    it "create a cancellation procedure" do
      allow(person_proxy).to receive(:create_cancellation)
      subject
      expect(person_proxy).to have_received(:create_cancellation)
    end
  end
end
