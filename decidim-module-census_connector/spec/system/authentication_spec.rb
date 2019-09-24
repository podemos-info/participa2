# frozen_string_literal: true

require "spec_helper"
require "decidim/core/test/factories"

module Decidim
  describe "Authentication", type: :system do
    let(:organization) { create(:organization) }
    let(:last_user) { User.last }
    let(:password) { "SafePassword_456" }

    before do
      switch_to_host(organization.host)
      visit decidim.root_path
    end

    context "when a user is already registered" do
      let(:user) { create(:user, :confirmed, password: password, organization: organization) }

      describe "Sign in" do
        it "authenticates an existing User" do
          find(".sign-in-link").click

          within ".new_user" do
            fill_in :user_email, with: user.email
            fill_in :user_password, with: password
            find("*[type=submit]").click
          end

          expect(page).to have_content("Signed in successfully")
          expect(page).to have_content(user.name)
        end

        context "when logging in with the document ID" do
          let(:user) { create(:user, :confirmed, :with_person, password: password, organization: organization) }
          let(:person) { person_proxy.person }
          let(:person_proxy) { CensusConnector::PersonProxy.for(user) }
          let(:cassette) { "authentication_with_document" }

          around do |example|
            VCR.use_cassette(cassette, {}, &example)
          end

          before do
            # rubocop:disable Rails/SkipsModelValidations
            user.update_columns email: person.email
            # rubocop:enable Rails/SkipsModelValidations
          end

          it "authenticates an existing User" do
            find(".sign-in-link").click

            within ".new_user" do
              fill_in :user_email, with: person.document_id
              fill_in :user_password, with: password
              find("*[type=submit]").click
            end

            expect(page).to have_content("Signed in successfully")
            expect(page).to have_content(user.name)
          end
        end
      end
    end
  end
end
