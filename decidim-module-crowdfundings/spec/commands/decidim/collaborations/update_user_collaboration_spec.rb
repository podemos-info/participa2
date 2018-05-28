# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Collaborations
    describe UpdateUserCollaboration do
      subject { described_class.new(form) }

      let(:organization) { create(:organization) }
      let(:participatory_process) { create :participatory_process, organization: organization }
      let(:current_component) { create :collaboration_component, participatory_space: participatory_process }
      let(:collaboration) { create(:collaboration, component: current_component) }
      let(:user) { create(:user, organization: organization) }
      let(:user_collaboration) do
        create(:user_collaboration,
               :monthly,
               :accepted,
               user: user,
               collaboration: collaboration)
      end

      let(:context) do
        {
          current_organization: organization,
          current_component: current_component,
          collaboration: collaboration,
          user_collaboration: user_collaboration,
          current_user: user
        }
      end

      let(:amount) { ::Faker::Number.number(4).to_i }
      let(:frequency) { "punctual" }

      let(:form) do
        Decidim::Collaborations::UserProfile::UserCollaborationForm
          .new(
            amount: amount,
            frequency: frequency
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
        before do
          stub_totals_service_down
        end

        it "is not valid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end

      context "when everything is ok" do
        before do
          stub_totals_request(0)
        end

        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
        end
      end
    end
  end
end
