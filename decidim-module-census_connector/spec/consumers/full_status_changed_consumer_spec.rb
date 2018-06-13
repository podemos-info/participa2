# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/factories"

module Decidim::CensusConnector
  describe FullStatusChangedConsumer do
    subject(:process) { described_class.new.process(message) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization: organization) }
    let!(:authorization) { create(:authorization, :granted, name: "census", user: user, metadata: { person_id: person_id }) }

    let(:message) { instance_double(Hutch::Message, body: params.stringify_keys) }

    let(:params) do
      {
        person: qualified_id,
        state: state,
        membership_level: membership_level,
        verification: verification,
        scope: scope_code
      }
    end

    let(:qualified_id) { "#{person_id}@census" }
    let(:person_id) { 1 }
    let(:state) { "enabled" }
    let(:membership_level) { "follower" }
    let(:verification) { "not_verified" }
    let(:scope_code) { create(:scope, organization: organization).code }

    it "doesn't update user person_id" do
      expect { subject } .not_to change { authorization.reload.metadata["person_id"] }
    end

    it "updates person state metadata" do
      expect { subject } .to change { authorization.reload.metadata["state"] } .from(nil).to(state)
    end

    it "updates person state membership_level" do
      expect { subject } .to change { authorization.reload.metadata["membership_level"] } .from(nil).to(membership_level)
    end

    it "updates person state verification" do
      expect { subject } .to change { authorization.reload.metadata["verification"] } .from(nil).to(verification)
    end

    it "updates person state scope" do
      expect { subject } .to change { authorization.reload.metadata["scope"] } .from(nil).to(scope_code)
    end

    context "when person is discarded" do
      let(:params) do
        {
          person: qualified_id,
          state: "trashed",
          verification: "mistake"
        }
      end

      it "doesn't update user person_id" do
        expect { subject } .not_to change { authorization.reload.metadata["person_id"] }
      end

      it "updates person state metadata" do
        expect { subject } .to change { authorization.reload.metadata["state"] } .from(nil).to("trashed")
      end

      it "updates person state verification" do
        expect { subject } .to change { authorization.reload.metadata["verification"] } .from(nil).to("mistake")
      end
    end

    context "when there is no user for that person id" do
      let(:qualified_id) { "42@census" }

      it "does not fail" do
        is_expected.to eq(nil)
      end
    end
  end
end