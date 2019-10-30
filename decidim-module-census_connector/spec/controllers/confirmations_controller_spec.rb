# frozen_string_literal: true

require "spec_helper"

module Decidim::Devise
  describe ConfirmationsController, :vcr, type: :controller do
    routes { Decidim::Core::Engine.routes }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :with_person, :confirmed, person_id: 10) }
    let(:email) { "test@example.org" }
    let(:person_proxy) { Decidim::CensusConnector::PersonProxy.for(user) }

    before do
      request.env["devise.mapping"] = Devise.mappings[:user]
      request.env["decidim.current_organization"] = organization

      allow(controller).to receive(:person_proxy).and_return(person_proxy)

      user.email = email
      user.save!
    end

    describe "show page" do
      subject { get :show, params: params }

      before { allow(person_proxy).to receive(:update).and_return(census_result) }

      let(:confirmation_token) { user.confirmation_token }
      let(:census_result) { [:ok, []] }
      let(:params) do
        {
          confirmation_token: confirmation_token
        }
      end

      it "update census data" do
        subject
        expect(person_proxy).to have_received(:update)
        expect(controller.response).to redirect_to(new_user_session_path)
        expect(controller.flash.notice).to have_content("Your email address has been successfully confirmed.")
      end

      context "when update fails" do
        let(:census_result) { [:error, []] }

        it "doesn't updates census data" do
          subject
          expect(person_proxy).to have_received(:update)
          expect(controller.response).to redirect_to(root_path)
          expect(controller.flash.alert).to have_content("Your registration can't be updated when the census service is not available. Please, try again later or contact us if the problem persists.")
        end
      end
    end
  end
end
