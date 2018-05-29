# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Collaborations
    describe CreateUserCollaboration do
      subject { described_class.new(form) }

      let(:organization) { create(:organization) }
      let(:participatory_process) { create :participatory_process, organization: organization }
      let(:current_component) { create :collaboration_component, participatory_space: participatory_process }
      let(:collaboration) { create(:collaboration, component: current_component) }
      let(:user) { create(:user, organization: organization) }

      let(:context) do
        {
          current_organization: organization,
          current_component: current_component,
          collaboration: collaboration,
          current_user: user
        }
      end

      let(:amount) { ::Faker::Number.number(4).to_i }
      let(:frequency) { "punctual" }
      let(:payment_method_type) { "existing_payment_method" }
      let(:payment_method_id) { 1 }
      let(:iban) { nil }
      let(:over_18) { true }
      let(:accept_terms_and_conditions) { true }

      let(:form) do
        ConfirmUserCollaborationForm
          .new(
            amount: amount,
            frequency: frequency,
            payment_method_type: payment_method_type,
            payment_method_id: payment_method_id,
            iban: iban,
            over_18: over_18,
            accept_terms_and_conditions: accept_terms_and_conditions
          ).with_context(context)
      end

      before do
        stub_totals_request(0)
      end

      context "when the form is not valid" do
        before do
          allow(form).to receive(:invalid?).and_return(true)
        end

        it "is not valid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when census service is down" do
        let(:response) do
          Net::HTTPServiceUnavailable.new("1.1", 503, "Service Unavailable")
        end

        let(:exception) do
          Net::HTTPFatalError.new("503 Service Unavailable", response)
        end

        before do
          allow(::Census::API::Order).to receive(:post)
            .with("/api/v1/payments/orders", anything)
            .and_raise(exception)
        end

        it "do not creates the collaboration" do
          expect { subject.call }.to change { Decidim::Collaborations::UserCollaboration.count }.by(0)
        end

        it "is not valid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when census API rejects the request" do
        before do
          stub_request(:post, %r{/api/v1/payments/orders})
            .to_return(
              status: 422,
              body: { errorCode: 1, errorMessage: "Error message" }.to_json,
              headers: {}
            )
        end

        it "do not creates the collaboration" do
          expect { subject.call }.to change { Decidim::Collaborations::UserCollaboration.count }.by(0)
        end

        it "is not valid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when everything is ok" do
        before do
          stub_request(:post, %r{/api/v1/payments/orders})
            .to_return(
              status: http_response_code,
              body: json.to_json,
              headers: {}
            )
        end

        let(:returned_payment_method_id) { 74 }
        let(:user_collaboration) do
          Decidim::Collaborations::UserCollaboration.last
        end

        context "with existing payment method / Direct debit" do
          let(:json) { { payment_method_id: returned_payment_method_id } }
          let(:http_response_code) { 201 }

          it "creates the collaboration" do
            expect { subject.call }.to change { Decidim::Collaborations::UserCollaboration.count }.by(1)
          end

          it "is valid" do
            expect { subject.call }.to broadcast(:ok)
          end

          it "Created user collaboration is accepted" do
            subject.call
            expect(user_collaboration).to be_accepted
          end

          it "Sets all attributes received from the form" do
            subject.call
            expect(user_collaboration.amount.to_i).to eq(amount)
            expect(user_collaboration.frequency).to eq(frequency)
            expect(user_collaboration.collaboration).to eq(collaboration)
            expect(user_collaboration.user).to eq(user)
          end

          it "Last request date is set to the first of the month when happened" do
            subject.call
            expect(user_collaboration.last_order_request_date).to eq(Time.zone.today.beginning_of_month)
          end

          it "Payment method id is set with the value received from census" do
            subject.call
            expect(user_collaboration.payment_method_id).to eq(returned_payment_method_id)
          end
        end

        context "with credit card" do
          let(:payment_method_type) { "credit_card_external" }
          let(:json) do
            {
              payment_method_id: returned_payment_method_id
            }
          end
          let(:http_response_code) { 202 }

          before do
            # rubocop:disable RSpec/SubjectStub
            allow(subject).to receive(:validate_user_collaboration_url)
              .with(collaboration, anything)
              .and_return("http://localhost:3000")
            # rubocop:enable RSpec/SubjectStub
          end

          it "creates the collaboration" do
            expect { subject.call }.to change { Decidim::Collaborations::UserCollaboration.count }.by(1)
          end

          it "broadcast credit card response" do
            expect { subject.call }.to broadcast(:credit_card)
          end

          it "Created user collaboration is pending" do
            subject.call
            expect(user_collaboration).to be_pending
          end
        end
      end
    end
  end
end
