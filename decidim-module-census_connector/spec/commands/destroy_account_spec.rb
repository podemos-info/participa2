# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DestroyAccount do
    subject(:command) { described_class.new(user, form) }

    around do |example|
      VCR.use_cassette(cassette, {}, &example)
    end

    let(:user) { create(:user, :with_person, :confirmed, person_id: 5) }
    let(:person_proxy) { Decidim::CensusConnector::PersonProxy.for(user) }
    let!(:identity) { create(:identity, user: user) }
    let(:valid) { true }
    let(:data) do
      {
        delete_reason: "I want to delete my account"
      }
    end

    let(:form) do
      double(
        delete_reason: data[:delete_reason],
        valid?: valid,
        context: double(
          person_proxy: person_proxy
        )
      )
    end

    context "when valid" do
      let(:cassette) { "destroy_account_ok" }
      let(:valid) { true }

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "stores the deleted_at and delete_reason to the user" do
        subject.call
        expect(user.reload.delete_reason).to eq(data[:delete_reason])
        expect(user.reload.deleted_at).not_to be_nil
      end

      it "set name, nickname and email to blank string" do
        subject.call
        expect(user.reload.name).to eq("")
        expect(user.reload.nickname).to eq("")
        expect(user.reload.email).to eq("")
      end

      it "destroys the current user avatar" do
        subject.call
        expect(user.reload.avatar).not_to be_present
      end

      it "deletes user's identities" do
        expect { subject.call } .to change(Identity, :count).by(-1)
      end

      it "deletes user group memberships" do
        user_group = create(:user_group)
        create(:user_group_membership, user_group: user_group, user: user)

        expect { subject.call } .to change(UserGroupMembership, :count).by(-1)
      end

      it "create a cancellation procedure" do
        allow(person_proxy).to receive(:create_cancellation)
        subject.call
        expect(person_proxy).to have_received(:create_cancellation)
      end
    end

    context "when invalid" do
      let(:cassette) { "destroy_account_invalid" }
      let(:valid) { false }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "create a cancellation procedure" do
        allow(person_proxy).to receive(:create_cancellation)
        subject.call
        expect(person_proxy).not_to have_received(:create_cancellation)
      end
    end
  end
end
