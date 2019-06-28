# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/factories"
require "faker/spanish_document"

module Decidim::CensusConnector
  describe Verifications::Census::PerformCensusPhoneVerificationStep do
    subject { described_class.new(person_proxy, form) }

    around do |example|
      VCR.use_cassette(cassette, {}, &example)
    end

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :with_person, organization: organization) }

    let(:person_proxy) { PersonProxy.for(user) }

    let(:received_code) { "2943577" }
    let(:params) { { part: "" } }

    let(:form) do
      Verifications::Census::PhoneVerificationForm.new(
        received_code: received_code
      ).with_context(
        params: params,
        person: person_proxy.person
      )
    end

    let(:cassette) { "phone_verification_step_ok" }

    it "broadcasts :ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    context "when received code is invalid" do
      let(:cassette) { "phone_verification_step_received_code_invalid" }

      it "broadcasts :invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "adds the API error to the form" do
        subject.call

        expect(form.errors.count).to eq(1)
        expect(form.errors[:received_code]).to eq(["is invalid"])
      end
    end
  end
end
