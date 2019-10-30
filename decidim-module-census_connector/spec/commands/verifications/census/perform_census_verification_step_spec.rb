# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/factories"

module Decidim::CensusConnector
  describe Verifications::Census::PerformCensusVerificationStep, :vcr do
    subject { described_class.new(person_proxy, form).call }

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
        member: member,
      ).with_context(
        params: { part: "" },
        person: person_proxy.person
      )
    end

    let(:member) { false }

    let(:member_request) do
      a_request(:post, "http://mycensus:3001/api/v1/en/people/7@census/membership_levels")
        .with(body: hash_including(membership_level: "member"))
    end

    it { expect { subject }.to broadcast(:ok) }
    it { subject; expect(member_request).not_to have_been_made }

    context "when user request to be a member too" do
      let(:member) { true }

      it { expect { subject }.to broadcast(:ok) }
      it { subject; expect(member_request).to have_been_made.once }
    end
    it { subject; expect(member_request).not_to have_been_made }
    context "when no document files present" do
      let(:person_id) { 8 }
      let(:document_file1) { nil }

      it "broadcasts :invalid" do
        expect { subject }.to broadcast(:invalid)
      end

      it "adds the API error to the form" do
        subject

        expect(form.errors.count).to eq(2)
        expect(form.errors[:document_file1]).to eq(["can't be empty"])
        expect(form.errors[:document_file2]).to eq(["can't be empty"])
      end
    end
  end
end
