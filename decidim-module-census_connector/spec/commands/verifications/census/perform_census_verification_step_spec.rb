# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/factories"
require "faker/spanish_document"

module Decidim::CensusConnector
  describe Verifications::Census::PerformCensusVerificationStep do
    subject { described_class.new(person_proxy, form) }

    around do |example|
      VCR.use_cassette(cassette, {}, &example)
    end

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :with_person, organization: organization, person_id: person_id) }
    let(:person_id) { 7 }
    let(:person_proxy) { PersonProxy.for(user) }

    let(:document_file1) do
      Rack::Test::UploadedFile.new(Decidim::Dev.test_file("id.jpg", "image/jpg"), "image/jpg")
    end
    let(:document_file2) do
      Rack::Test::UploadedFile.new(Decidim::Dev.test_file("id.jpg", "image/jpg"), "image/jpg")
    end

    let(:form) do
      Verifications::Census::VerificationForm.new(
        document_file1: document_file1,
        document_file2: document_file2,
        member: true
      ).with_context(
        params: { part: "" },
        person: person_proxy.person
      )
    end

    let(:cassette) { "verification_step_ok" }

    it "broadcasts :ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    context "when no document files present" do
      let(:person_id) { 8 }
      let(:document_file1) { nil }
      let(:cassette) { "verification_step_files_missing" }

      it "broadcasts :invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "adds the API error to the form" do
        subject.call

        expect(form.errors.count).to eq(2)
        expect(form.errors[:document_file1]).to eq(["can't be empty"])
        expect(form.errors[:document_file2]).to eq(["can't be empty"])
      end
    end
  end
end
