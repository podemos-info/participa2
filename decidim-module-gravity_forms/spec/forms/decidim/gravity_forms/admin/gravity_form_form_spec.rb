# frozen_string_literal: true

require "spec_helper"

describe Decidim::GravityForms::Admin::GravityFormForm do
  subject { described_class.from_params(attributes).with_context(context) }

  let(:organization) { create(:organization) }

  let(:context) do
    {
      current_organization: organization,
      current_component: current_component
    }
  end

  let(:participatory_process) do
    create :participatory_process, organization: organization
  end

  let(:current_component) do
    create :component, participatory_space: participatory_process
  end

  let(:title) { Decidim::Faker::Localized.sentence }
  let(:description) { Decidim::Faker::Localized.sentence(3) }
  let(:slug) { "my-slug" }
  let(:form_number) { 1 }
  let(:require_login) { true }
  let(:hidden) { false }

  let(:attributes) do
    {
      title: title,
      description: description,
      slug: slug,
      form_number: form_number,
      require_login: require_login,
      hidden: hidden
    }
  end

  it { is_expected.to be_valid }

  describe "when title is missing" do
    let(:title) { { ca: nil, es: nil } }

    it { is_expected.not_to be_valid }
  end

  describe "when slug is missing" do
    let(:slug) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when slug is empty" do
    let(:slug) { "" }

    it { is_expected.not_to be_valid }
  end

  describe "when slug is invalid" do
    let(:slug) { "I n v a l i d" }

    it { is_expected.not_to be_valid }
  end

  describe "when slug is not unique" do
    before { create(:gravity_form, component: current_component, slug: slug) }

    it { is_expected.not_to be_valid }
  end

  describe "when form number is missing" do
    let(:form_number) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when form number is empty" do
    let(:form_number) { "" }

    it { is_expected.not_to be_valid }
  end

  describe "when form number is a string" do
    let(:form_number) { "KAX" }

    it { is_expected.not_to be_valid }
  end

  describe "when form number is a negative integer" do
    let(:form_number) { -5 }

    it { is_expected.not_to be_valid }
  end

  describe "when form number is zero" do
    let(:form_number) { 0 }

    it { is_expected.not_to be_valid }
  end

  describe "when require_login is nil" do
    let(:require_login) { nil }

    it { is_expected.not_to be_valid }
  end

  describe "when hidden is nil" do
    let(:hidden) { nil }

    it { is_expected.not_to be_valid }
  end
end
