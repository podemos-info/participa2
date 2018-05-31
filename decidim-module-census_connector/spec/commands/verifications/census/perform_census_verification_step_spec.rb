# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/factories"
require "faker/spanish_document"

module Decidim::CensusConnector
  describe Verifications::Census::PerformCensusVerificationStep do
    subject { described_class.new(authorization, form) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization: organization) }

    let!(:authorization) { create(:authorization, name: "census", user: user, metadata: { "person_id" => 1 }) }

    let(:person_proxy) { PersonProxy.for(user) }

    let(:document_file1) do
      Rack::Test::UploadedFile.new(Decidim::Dev.test_file("id.jpg", "image/jpg"))
    end

    let(:form) do
      Verifications::Census::VerificationForm.new(document_file1: document_file1).with_context(person_proxy: person_proxy)
    end

    context "when no document files present" do
      let(:document_file1) { nil }

      it "adds the API error to the form" do
        stub_request(:post, "http://mycensus:3001/api/v1/people/1@census/document_verifications")
          .to_return(status: 422, body: '{"files": ["es demasiado corto (2 caracteres mínimo)"]}')

        expect { subject.call }.to broadcast(:invalid, ["files: es demasiado corto (2 caracteres mínimo)"])
      end
    end
  end
end
