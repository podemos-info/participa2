# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/factories"
require "faker/spanish_document"

module Decidim::CensusConnector
  describe Verifications::Census::PerformCensusDataStep do
    subject { described_class.new(person_proxy, form) }

    around do |example|
      VCR.use_cassette(cassette, {}, &example)
    end

    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization: organization) }

    let!(:local_scope) { create(:scope, code: scope_code, organization: organization) }
    let!(:foreign_scope) { create(:scope, code: foreign_scope_code, organization: organization) }
    let!(:unrelated_scope) { create(:scope) }

    let(:scope_code) { "ES" }
    let(:foreign_scope_code) { "XX" }

    let(:person_proxy) { PersonProxy.for(user) }
    let(:person) { person_proxy.person }

    let(:first_name) { Faker::Name.first_name }
    let(:last_name1) { Faker::Name.last_name }
    let(:document_type) { :dni }
    let(:document_id) { Faker::SpanishDocument.generate(document_type) }
    let(:born_at) { Faker::Date.between(99.years.ago, 18.years.ago) }
    let(:gender) { "female" }
    let(:address) { "Rua del Percebe, 1" }
    let(:postal_code) { "08001" }
    let(:phone_country) { "ES" }
    let(:phone_number) { Faker::Number.number(9) }
    let(:verify_phone) { false }

    let(:address_scope) { local_scope }
    let(:address_scope_id) { address_scope.id }

    let(:document_scope) { local_scope }
    let(:document_scope_id) { document_scope.id }

    let(:scope) { local_scope }
    let(:scope_id) { scope.id }

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
        postal_code: postal_code,
        phone_country: phone_country,
        phone_number: phone_number,
        verify_phone: verify_phone
      ).with_context(
        local_scope: local_scope,
        params: { part: "" },
        person: person_proxy.person
      )
    end

    let(:cassette) { "data_step_#{cassette_target}_#{cassette_status}" }
    let(:cassette_target) { "everything" }
    let(:cassette_status) { "ok" }

    it "broadcasts :ok" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "doesn't start a phone verification" do
      allow(person_proxy).to receive(:start_phone_verification)
      subject.call
      expect(person_proxy).not_to have_received(:start_phone_verification)
    end

    context "when phone verification is required" do
      let(:cassette_target) { "verify_phone" }
      let(:cassette_status) { "ok" }
      let(:phone_number) { "666666666" }
      let(:verify_phone) { true }

      it "broadcasts :ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "starts a phone verification" do
        allow(person_proxy).to receive(:start_phone_verification)
        subject.call
        expect(person_proxy).to have_received(:start_phone_verification)
      end
    end

    context "when document id not present" do
      let(:document_id) { "" }
      let(:cassette_target) { "document_id" }
      let(:cassette_status) { "missing" }

      it "broadcasts :invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "adds the API error to the form" do
        subject.call
        expect(form.errors.count).to eq(1)
        expect(form.errors.first).to eq([:document_id, "can't be blank"])
      end
    end

    context "when document id invalid" do
      let(:document_id) { "11111111A" }
      let(:cassette_target) { "document_id" }
      let(:cassette_status) { "invalid" }

      it "broadcasts :invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "adds the API error to the form" do
        subject.call
        expect(form.errors.count).to eq(1)
        expect(form.errors.first).to eq([:document_id, "is invalid"])
      end
    end

    context "when first name not present" do
      let(:first_name) { "" }
      let(:cassette_target) { "first_name" }
      let(:cassette_status) { "missing" }

      it "broadcasts :invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "adds the API error to the form" do
        subject.call
        expect(form.errors.count).to eq(1)
        expect(form.errors.first).to eq([:first_name, "can't be blank"])
      end
    end

    context "when first last name not present" do
      let(:last_name1) { "" }
      let(:cassette_target) { "last_name" }
      let(:cassette_status) { "missing" }

      it "broadcasts :invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "adds the API error to the form" do
        subject.call
        expect(form.errors.count).to eq(1)
        expect(form.errors.first).to eq([:last_name1, "can't be blank"])
      end
    end

    context "when birth date not present" do
      let(:born_at) { "" }
      let(:cassette_target) { "born_at" }
      let(:cassette_status) { "missing" }

      it "broadcasts :invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "adds the API error to the form" do
        subject.call
        expect(form.errors.count).to eq(1)
        expect(form.errors[:born_at]).to eq(["can't be blank"])
      end
    end

    context "when birth date is invalid" do
      let(:born_at) { "potato" }
      let(:cassette_target) { "born_at" }
      let(:cassette_status) { "invalid" }

      it "broadcasts :invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "adds the API error to the form" do
        subject.call
        expect(form.errors.count).to eq(1)
        expect(form.errors[:born_at]).to eq(["is invalid"])
      end
    end

    context "when gender not present" do
      let(:gender) { "" }
      let(:cassette_target) { "gender" }
      let(:cassette_status) { "missing" }

      it "broadcasts :invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "adds the API errors to the form" do
        subject.call
        expect(form.errors.count).to eq(1)
        expect(form.errors[:gender]).to eq(["can't be blank"])
      end
    end

    context "when gender invalid" do
      let(:gender) { "ardilla" }
      let(:cassette_target) { "gender" }
      let(:cassette_status) { "invalid" }

      it "broadcasts :invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "adds the API errors to the form" do
        subject.call
        expect(form.errors.count).to eq(1)
        expect(form.errors[:gender]).to eq(["is not included in the list"])
      end
    end

    context "when address not present" do
      let(:address) { "" }
      let(:cassette_target) { "address" }
      let(:cassette_status) { "missing" }

      it "broadcasts :invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "adds the API errors to the form" do
        subject.call
        expect(form.errors.count).to eq(1)
        expect(form.errors[:address]).to eq(["can't be blank"])
      end
    end

    context "when postal code not present" do
      let(:postal_code) { "" }
      let(:cassette_target) { "postal_code" }
      let(:cassette_status) { "missing" }

      it "broadcasts :invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "adds the API errors to the form" do
        subject.call
        expect(form.errors.count).to eq(1)
        expect(form.errors[:postal_code]).to eq(["can't be blank"])
      end
    end

    context "when address_scope_id not present" do
      let(:address_scope_id) { "" }
      let(:cassette_target) { "address_scope_id" }
      let(:cassette_status) { "missing" }

      it "broadcasts :invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "adds the API errors to the form" do
        subject.call
        expect(form.errors.count).to eq(1)
        expect(form.errors[:address_scope_id]).to eq(["can't be blank"])
      end
    end

    context "when address_scope_id in other organization" do
      let(:address_scope_id) { unrelated_scope.id }
      let(:cassette_target) { "address_scope_id" }
      let(:cassette_status) { "invalid" }

      it "broadcasts :invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      it "adds the API errors to the form" do
        subject.call
        expect(form.errors.count).to eq(1)
        expect(form.errors[:address_scope_id]).to eq(["can't be blank"])
      end
    end

    context "when document_scope_id not present" do
      let(:document_scope_id) { nil }

      context "and document_type local" do
        let(:document_type) { "dni" }
        let(:cassette_target) { "document_scope_id" }
        let(:cassette_status) { "inferred" }

        it "broadcasts :ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "uses the local scope" do
          subject.call

          expect(person.document_scope).to eq(local_scope)
        end
      end

      context "and document_type not local" do
        before { allow(form).to receive(:document_scope_id).and_return(nil) }

        let(:document_type) { "passport" }
        let(:cassette_target) { "document_scope_id" }
        let(:cassette_status) { "missing" }

        it "broadcasts :invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end

        it "adds the API errors to the form" do
          subject.call
          expect(form.errors.count).to eq(1)
          expect(form.errors[:document_scope_id]).to eq(["can't be blank"])
        end
      end
    end

    context "when document_scope_id in other organization" do
      let(:document_scope_id) { unrelated_scope.id }

      context "and document_type local" do
        let(:document_type) { "dni" }
        let(:cassette_target) { "document_scope_id" }
        let(:cassette_status) { "invalid_but_inferred" }

        it "broadcasts :ok" do
          expect { subject.call }.to broadcast(:ok)
        end

        it "uses the local scope" do
          subject.call

          expect(person.document_scope).to eq(local_scope)
        end
      end

      context "and document_type not local" do
        let(:document_type) { "passport" }
        let(:cassette_target) { "document_scope_id" }
        let(:cassette_status) { "invalid" }

        it "broadcasts :invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end

        it "adds the API errors to the form" do
          subject.call
          expect(form.errors.count).to eq(1)
          expect(form.errors[:document_scope_id]).to eq(["can't be blank"])
        end
      end
    end

    shared_examples_for "missing scope_id" do
      context "and address_scope_id not present either" do
        let(:address_scope_id) { nil }
        let(:cassette) { "data_step_#{cassette_target}_#{cassette_status}_without_address" }

        it "broadcasts :invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end

        it "adds API errors to the form" do
          subject.call
          expect(form.errors.count).to eq(2)
          expect(form.errors[:scope_id]).to eq(["can't be blank"])
          expect(form.errors[:address_scope_id]).to eq(["can't be blank"])
        end
      end

      context "and address_scope_id present" do
        context "and local" do
          let(:address_scope_id) { local_scope.id }
          let(:cassette) { "data_step_#{cassette_target}_#{cassette_status}_with_local_address" }

          it "broadcasts :ok" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "uses the address scope" do
            subject.call

            expect(person.scope).to eq(person.address_scope)
          end
        end

        context "and not local" do
          let(:address_scope_id) { foreign_scope.id }
          let(:cassette) { "data_step_#{cassette_target}_#{cassette_status}_with_foreign_address" }

          it "broadcasts :invalid" do
            expect { subject.call }.to broadcast(:invalid)
          end

          it "adds the API errors to the form" do
            subject.call
            expect(form.errors.count).to eq(1)
            expect(form.errors[:scope_id]).to eq(["can't be blank"])
          end
        end
      end
    end

    context "when scope_id not present" do
      let(:scope_id) { nil }
      let(:cassette_target) { "scope_id" }
      let(:cassette_status) { "missing" }

      include_examples "missing scope_id"
    end

    context "when scope_id not in organization" do
      let(:scope_id) { unrelated_scope.id }
      let(:cassette_target) { "scope_id" }
      let(:cassette_status) { "invalid" }

      include_examples "missing scope_id"
    end
  end
end
