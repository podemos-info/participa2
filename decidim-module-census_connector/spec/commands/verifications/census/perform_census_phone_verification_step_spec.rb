# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/factories"

module Decidim::CensusConnector
  describe Verifications::Census::PerformCensusPhoneVerificationStep, :vcr do
    subject { described_class.new(person_proxy, form).call }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :with_person, organization: organization, person_id: 6) }

    let(:person_proxy) { PersonProxy.for(user) }

    let(:received_code) { "9999999" }
    let(:params) { { part: "" } }

    let(:form) do
      Verifications::Census::PhoneVerificationForm.new(
        received_code: received_code
      ).with_context(
        params: params,
        person: person_proxy.person
      )
    end

    it "broadcasts :ok" do
      expect { subject }.to broadcast(:ok)
    end

    context "when received code is invalid" do
      let(:received_code) { "0000000" }

      it "broadcasts :invalid" do
        expect { subject }.to broadcast(:invalid)
      end

      it "adds the API error to the form" do
        subject

        expect(form.errors.count).to eq(1)
        expect(form.errors[:received_code]).to eq(["is invalid"])
      end
    end
  end
end
