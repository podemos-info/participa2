# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/factories"
require "faker/spanish_document"

module Decidim::CensusConnector
  describe Verifications::Census::PerformCensusVerificationStep do
    subject { described_class.new(person_proxy, form) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization: organization) }

    let(:person_proxy) { PersonProxy.for(user) }

    let(:document_file1) do
      Rack::Test::UploadedFile.new(Decidim::Dev.test_file("id.jpg", "image/jpg"))
    end

    let(:form) do
      Verifications::Census::VerificationForm.new(document_file1: document_file1)
    end

    before do
      create(:authorization, name: "census", user: user, metadata: { "person_id" => 1 })
    end

    context "when no document files present" do
      let(:document_file1) { nil }

      before do
        stub_request(:post, "http://mycensus:3001/api/v1/people/1@census/document_verifications")
          .to_return(status: 422, body: '{"files":[{"error":"too_short"}]}')
      end

      it "adds the API error to the form" do
        subject.call

        expect(form.errors.count).to eq(1)
        expect(form.errors.first).to eq([:files, "Is too short"])
      end

      it "broadcasts a global error message" do
        expect { subject.call }.to broadcast(:invalid, "Files Is too short")
      end
    end
  end
end
