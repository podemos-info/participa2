# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/factories"
require "decidim/census_connector/verifications/census/action_authorizer"

module Decidim::CensusConnector::Verifications::Census
  describe ActionAuthorizer do
    subject(:authorizer) { described_class.new(authorization, options, component, resource) }

    around do |example|
      VCR.use_cassette(cassette, {}, &example)
    end

    let(:user) { create(:user, :confirmed, :with_person, organization: organization, scope: user_scope) }
    let(:user_scope) { nil }
    let(:person) { person_proxy.person }
    let(:person_proxy) { Decidim::CensusConnector::PersonProxy.for(user) }

    let(:authorization) { Decidim::Authorization.find_by(user: user, name: "census") }
    let(:verification_metadata) { {} }

    let(:options) { {} }

    let(:resource) { create(:dummy_resource, component: component, scope: resource_scope) }
    let(:resource_scope) { nil }

    let(:component) do
      create(
        :component,
        permissions: {
          "foo" => {
            "authorization_handler_name" => "census",
            "options" => options
          }
        }
      )
    end
    let(:organization) { component.organization }
    let(:cassette) { "unused_cassette" }

    describe "#authorize" do
      subject(:method_call) { authorizer.authorize }

      it { expect(subject.first).to eq(:ok) }
      it { expect(subject.last).to be_empty }

      context "when enforcing scope" do
        let(:options) { { "enforce_scope" => 1 } }
        let(:resource_scope) { create(:scope, organization: organization) }
        let(:user_scope) { resource_scope }

        it { expect(subject.first).to eq(:ok) }
        it { expect(subject.last).to be_empty }

        context "when user doesn't have scope" do
          let(:user_scope) { create(:scope) } # creates an invalid scope to simulate a nil scope without API interaction

          it { expect(subject.first).to eq(:incomplete) }
          it "explains that user should select a territory" do
            expect(subject.last).to eq(
              action: :complete,
              cancel: true,
              extra_explanation: { key: "decidim.authorization_handlers.census.extra_explanation.scope", params: {} }
            )
          end
        end

        context "when scopes from resource and user doesn't match" do
          let(:user_scope) { create(:scope, organization: organization) }

          it { expect(subject.first).to eq(:unauthorized) }
          it "explains that user can participate in this territory" do
            expect(subject.last).to eq(
              extra_explanation: { key: "decidim.authorization_handlers.census.extra_explanation.scope", params: {} }
            )
          end
        end

        context "when census is closed" do
          let(:options) { { "enforce_scope" => 1, "census_closure" => 1.day.ago.to_s(:db) } }
          let(:cassette) { "person_closure" }
          let(:resource_scope) { create(:scope, organization: organization, code: resource_scope_code) }
          let(:user_scope) { nil }
          let(:resource_scope_code) { person.scope_code }

          it { expect(subject.first).to eq(:ok) }
          it { expect(subject.last).to be_empty }

          context "when user has changed its scope recently" do
            let(:resource_scope_code) { "ES-AN-CA-020" }
            let(:cassette) { "person_closure_with_scope_change" }

            before do
              resource_scope
              PerformCensusDataStep.call(
                person_proxy,
                DataForm.new(
                  scope: resource_scope_code
                ).with_context(
                  local_scope: create(:scope, :local),
                  params: { part: "" },
                  person: person
                )
              )
            end

            it { expect(subject.first).to eq(:unauthorized) }
            it "explains that user can participate in this territory" do
              expect(subject.last).to eq(
                extra_explanation: { key: "decidim.authorization_handlers.census.extra_explanation.closed_scope", params: {} }
              )
            end
          end
        end
      end
    end

    describe "#redirect_params" do
      subject(:method_call) { authorizer.redirect_params }

      it { is_expected.to eq(step: "data") }
    end
  end
end
