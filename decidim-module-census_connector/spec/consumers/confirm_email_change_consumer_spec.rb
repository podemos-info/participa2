# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/factories"

module Decidim::CensusConnector
  describe ConfirmEmailChangeConsumer do
    subject(:process) { described_class.new.process(message) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization: organization) }
    let!(:authorization) { create(:authorization, :granted, name: "census", user: user, metadata: { person_id: person_id }) }

    let(:message) { instance_double(Hutch::Message, body: params.stringify_keys) }

    let(:params) do
      {
        person: qualified_id,
        external_ids: external_ids,
        email: email
      }
    end

    let(:person_id) { 1 }
    let(:qualified_id) { "#{person_id}@census" }
    let(:external_ids) { { "#{Rails.application.engine_name}-#{organization.id}" => user.id } }
    let(:email) { "new_email@example.org" }

    it "doesn't update user person_id" do
      expect { subject } .not_to change { authorization.reload.metadata["person_id"] }
    end

    it "doesn't update user email" do
      expect { subject } .not_to change(user.reload, :email)
    end

    it "updates the user unconfirmed email" do
      expect { subject } .to change { user.reload.unconfirmed_email }.from(nil).to(email)
    end
  end
end
