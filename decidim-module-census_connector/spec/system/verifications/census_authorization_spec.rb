# frozen_string_literal: true

require "spec_helper"

require "faker"
require "faker/spanish_document"

describe "Census authorization", type: :system do
  let!(:organization) do
    create(:organization, available_authorizations: %w(census))
  end

  let!(:scope) { create(:scope, code: "ES", organization: organization) }

  let(:user) do
    create(:user, :confirmed, base_user_params.merge(extra_user_params))
  end

  let(:base_user_params) do
    {
      organization: organization,
      id: Faker::Number.number(7)
    }
  end

  let(:extra_user_params) do
    {}
  end

  let(:birth_date) { age.years.ago.strftime("%Y-%b-%-d") }

  let(:participatory_space) do
    create(:participatory_process, organization: organization)
  end

  let(:component) do
    create(
      :component,
      participatory_space: participatory_space,
      permissions: {
        "foo" => {
          "authorization_handler_name" => "census",
          "options" => {
            "minimum_age" => 18,
            "allowed_document_types" => "dni,nie"
          }
        }
      }
    )
  end

  let(:dummy_resource) { create(:dummy_resource, component: component) }

  let(:age) { 18 }
  let(:document_type) { "DNI" }

  let(:cassette) { "require_verification" }

  around do |example|
    VCR.use_cassette(cassette, {}, &example)
  end

  before do |example|
    Faker::Config.random = Random.new(XXhash.xxh32(example.full_description, 0)) # Random data should be deterministic to reuse vcr cassettes

    switch_to_host(organization.host)
    login_as user, scope: :user
    visit resource_locator(dummy_resource).path
    click_link "Foo"
  end

  it "shows popup to require verification" do
    expect(page).to have_content(
      'In order to perform this action, you need to be authorized with "Census"'
    )
  end

  context "when registering with census" do
    before do
      click_link 'Authorize with "Census"'

      register_with_census

      click_link "Foo"
    end

    context "and everything alright" do
      let(:cassette) { "regular_registration" }

      it "grants access to foo" do
        expect(page).to have_current_path(/foo/)
      end
    end

    context "and too young" do
      let(:age) { 14 }

      let(:cassette) { "child_registration" }

      it "shows popup to inform that requirements are not met" do
        expect(page).to have_content(
          "You need to be a least 18 years old."
        )
      end
    end

    context "and using passport" do
      let(:document_type) { "Passport" }

      let(:cassette) { "registration_with_passport" }

      it "shows popup to inform that requirements are not met" do
        expect(page).to have_content(
          "You need to be registered with DNI or NIE."
        )
      end
    end

    context "and registration has issues in the census side" do
      let(:extra_user_params) do
        { email: "scammer@mailinator.com" }
      end

      let(:cassette) { "registration_with_issues" }

      it "shows popup to require verification and shows it as pending" do
        expect(page).to have_content(
          "Your registration with Podemos is pending of approval."
        )
      end
    end
  end

  context "when registering with census with invalid data in the first step" do
    let(:cassette) { "registration_with_invalid_data" }

    before do
      click_link 'Authorize with "Census"'

      click_button "Send"
    end

    it "shows errors" do
      expect(page).to have_content("Name\ncan't be blank")
      expect(page).to have_content("First surname\ncan't be blank")
      expect(page).to have_content("Document\ncan't be blank")
      expect(page).to have_content("Birth date\ncan't be blank")
      expect(page).to have_content("Address\ncan't be blank")
      expect(page).to have_content("Postal code\ncan't be blank")
      expect(page).to have_content("City\nSelect a scope\ncan't be blank")
    end
  end

  context "when registering with census with invalid data in the second step" do
    let(:cassette) { "registration_with_invalid_data_second_step" }

    before do
      click_link 'Authorize with "Census"'

      complete_data_step

      click_button "Send"
    end

    it "shows errors" do
      expect(page).to have_content("can't be empty")
    end
  end

  private

  def register_with_census
    complete_data_step
    complete_document_step
  end

  def complete_data_step
    fill_in "Name", with: Faker::Name.first_name
    fill_in "First surname", with: Faker::Name.last_name

    select document_type, from: "Document type"

    fill_in "Document", with: Faker::SpanishDocument.generate(document_type.downcase.to_sym)

    choose "Female"

    year, month, day = birth_date.split("-")

    execute_script("$('#date_field_data_born_at').focus()")
    find(".datepicker-dropdown .year:not(.new):not(.old)", text: year, exact_text: true).click
    find(".datepicker-dropdown .month:not(.new):not(.old)", text: month, exact_text: true).click
    find(".datepicker-dropdown .day:not(.new):not(.old)", text: day, exact_text: true).click

    scope_pick select_data_picker(:data_address_scope_id), scope
    fill_in "Address", with: "Rua del Percebe, 1"
    fill_in "Postal code", with: "08001"

    click_button "Send"
  end

  def complete_document_step
    attach_file "verification_document_file1", Decidim::Dev.asset("id.jpg"), visible: false
    attach_file "verification_document_file2", Decidim::Dev.asset("id.jpg"), visible: false

    click_button "Send"
  end
end
