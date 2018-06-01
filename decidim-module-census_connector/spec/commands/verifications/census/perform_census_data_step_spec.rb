# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/factories"
require "faker/spanish_document"

module Decidim::CensusConnector
  describe Verifications::Census::PerformCensusDataStep do
    subject { described_class.new(person_proxy, authorization, form) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization: organization) }

    let!(:authorization) { create(:authorization, name: "census", user: user, metadata: { "person_id" => 1 }) }

    let!(:local_scope) { create(:scope, code: scope_code, organization: organization) }
    let!(:foreign_scope) { create(:scope, organization: organization) }

    let(:scope_code) { "ES" }

    let(:person_proxy) { PersonProxy.for(user) }

    let(:first_name) { "Marlin" }
    let(:last_name1) { "D'Amore" }
    let(:document_type) { "dni" }
    let(:document_id) { Faker::SpanishDocument.generate(:dni) }
    let(:born_at) { 18.years.ago }
    let(:gender) { "female" }
    let(:address) { "Rua del Percebe, 1" }
    let(:postal_code) { "08001" }

    let(:address_scope_id) { local_scope.id }
    let(:document_scope_id) { local_scope.id }
    let(:scope_id) { local_scope.id }

    let(:form) do
      Verifications::Census::DataForm.new(
        first_name: first_name,
        last_name1: last_name1,
        document_type: document_type,
        document_id: document_id,
        document_scope_id: document_scope_id,
        born_at: born_at,
        gender: gender,
        address: address,
        address_scope_id: address_scope_id,
        scope_id: scope_id,
        postal_code: postal_code
      ).with_context(
        local_scope: local_scope
      )
    end

    before do
      stub_request(:get, "http://mycensus:3001/api/v1/people/1@census")
        .to_return(status: 200, body: '{"id":1}')
    end

    context "when document id not present" do
      let(:document_id) { "" }

      before do
        stub_request(:patch, "http://mycensus:3001/api/v1/people/1@census")
          .with(body: hash_including(document_id: ""))
          .to_return(status: 422, body: '{"document_id":[{"error":"blank"}]}')

        subject.call
      end

      it "adds the API error to the form" do
        expect(form.errors.count).to eq(1)
        expect(form.errors.first).to eq([:document_id, "can't be blank"])
      end
    end

    context "when document id invalid" do
      let(:document_id) { "11111111A" }

      before do
        stub_request(:patch, "http://mycensus:3001/api/v1/people/1@census")
          .with(body: hash_including(document_id: "11111111A"))
          .to_return(status: 422, body: '{"document_id":[{"error":"invalid"}]}')

        subject.call
      end

      it "adds the API error to the form" do
        expect(form.errors.count).to eq(1)
        expect(form.errors.first).to eq([:document_id, "is invalid"])
      end
    end

    context "when first name not present" do
      let(:first_name) { "" }

      before do
        stub_request(:patch, "http://mycensus:3001/api/v1/people/1@census")
          .with(body: hash_including(first_name: ""))
          .to_return(status: 422, body: '{"first_name":[{"error":"blank"}]}')

        subject.call
      end

      it "adds the API error to the form" do
        expect(form.errors.count).to eq(1)
        expect(form.errors.first).to eq([:first_name, "can't be blank"])
      end
    end

    context "when first last name not present" do
      let(:last_name1) { "" }

      before do
        stub_request(:patch, "http://mycensus:3001/api/v1/people/1@census")
          .with(body: hash_including(last_name1: ""))
          .to_return(status: 422, body: '{"last_name1":[{"error":"blank"}]}')

        subject.call
      end

      it "adds the API error to the form" do
        expect(form.errors.count).to eq(1)
        expect(form.errors.first).to eq([:last_name1, "can't be blank"])
      end
    end

    context "when birth date not present" do
      let(:born_at) { "" }

      before do
        stub_request(:patch, "http://mycensus:3001/api/v1/people/1@census")
          .with(body: hash_including(born_at: ""))
          .to_return(status: 422, body: '{"born_at":[{"error":"blank"}]}')

        subject.call
      end

      it "adds the API error to the form" do
        expect(form.errors.count).to eq(1)
        expect(form.errors[:born_at]).to eq(["can't be blank"])
      end
    end

    context "when gender not present" do
      let(:gender) { "" }

      before do
        stub_request(:patch, "http://mycensus:3001/api/v1/people/1@census")
          .with(body: hash_including(gender: ""))
          .to_return(status: 422, body: '{"gender":[{"error":"blank"}]}')

        subject.call
      end

      it "adds the API errors to the form" do
        expect(form.errors.count).to eq(1)
        expect(form.errors[:gender]).to eq(["can't be blank"])
      end
    end

    context "when gender invalid" do
      let(:gender) { "ardilla" }

      before do
        stub_request(:patch, "http://mycensus:3001/api/v1/people/1@census")
          .with(body: hash_including(gender: "ardilla"))
          .to_return(status: 422, body: '{"gender":[{"error":"inclusion"}]}')

        subject.call
      end

      it "adds the API errors to the form" do
        expect(form.errors.count).to eq(1)
        expect(form.errors[:gender]).to eq(["is not included in the list"])
      end
    end

    context "when address not present" do
      let(:address) { "" }

      before do
        stub_request(:patch, "http://mycensus:3001/api/v1/people/1@census")
          .with(body: hash_including(address: ""))
          .to_return(status: 422, body: '{"address":[{"error":"blank"}]}')

        subject.call
      end

      it "adds the API errors to the form" do
        expect(form.errors.count).to eq(1)
        expect(form.errors[:address]).to eq(["can't be blank"])
      end
    end

    context "when postal code not present" do
      let(:postal_code) { "" }

      before do
        stub_request(:patch, "http://mycensus:3001/api/v1/people/1@census")
          .with(body: hash_including(postal_code: ""))
          .to_return(status: 422, body: '{"postal_code":[{"error":"blank"}]}')

        subject.call
      end

      it "adds the API errors to the form" do
        expect(form.errors.count).to eq(1)
        expect(form.errors[:postal_code]).to eq(["can't be blank"])
      end
    end

    context "when address_scope_id not present" do
      let(:address_scope_id) { nil }

      before do
        stub_request(:patch, "http://mycensus:3001/api/v1/people/1@census")
          .with(body: hash_including(address_scope_code: nil))
          .to_return(status: 422, body: '{"address_scope":[{"error":"blank"}]}')

        subject.call
      end

      it "adds the API errors to the form" do
        expect(form.errors.count).to eq(1)
        expect(form.errors[:address_scope_id]).to eq(["can't be blank"])
      end
    end

    context "when document_scope_id not present" do
      let(:document_scope_id) { nil }

      it "sends the local scope instead" do
        stub = stub_request(
          :patch, "http://mycensus:3001/api/v1/people/1@census"
        ).with(
          body: hash_including(document_scope_code: local_scope.code)
        ).to_return(status: 202, body: "{}")

        subject.call

        expect(stub).to have_been_requested
      end
    end

    context "when scope_id not present" do
      let(:scope_id) { nil }

      context "and address_scope_id not present either" do
        let(:address_scope_id) { nil }

        before do
          stub_request(:patch, "http://mycensus:3001/api/v1/people/1@census")
            .with(body: hash_including(address_scope_code: nil))
            .to_return(status: 422, body: '{"address_scope":[{"error":"blank"}]}')

          subject.call
        end

        it "adds API errors to the form" do
          expect(form.errors.count).to eq(1)
          expect(form.errors[:address_scope_id]).to eq(["can't be blank"])
        end
      end

      context "and address_scope_id present" do
        context "and local" do
          let(:address_scope_id) { local_scope.id }

          it "sends the address scope" do
            stub = stub_request(
              :patch, "http://mycensus:3001/api/v1/people/1@census"
            ).with(
              body: hash_including(scope_code: local_scope.code)
            ).to_return(status: 202, body: "{}")

            subject.call

            expect(stub).to have_been_requested
          end
        end

        context "and not local" do
          let(:address_scope_id) { foreign_scope.id }

          before do
            stub_request(:patch, "http://mycensus:3001/api/v1/people/1@census")
              .with(body: hash_including(scope_code: nil))
              .to_return(status: 422, body: '{"scope":[{"error":"blank"}]}')

            subject.call
          end

          it "adds the API errors to the form" do
            expect(form.errors.count).to eq(1)
            expect(form.errors[:scope_id]).to eq(["can't be blank"])
          end
        end
      end
    end
  end
end
