# frozen_string_literal: true

require "rails_helper"

require "decidim/census_connector/test/factories"

describe Decidim::ContentBlocks::HeroCell, :vcr, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  controller Decidim::PagesController

  let(:organization) { create(:organization) }
  let(:content_block) { create :content_block, organization: organization, manifest_name: :hero, scope: :homepage, settings: settings }
  let(:settings) { {} }
  let(:user) { create :user, organization: organization }

  before do
    allow(controller).to receive(:current_organization).and_return(organization)
    allow(controller).to receive(:current_user).and_return(user)
  end

  it "invites user to register in census" do
    expect(subject).to have_text("Inscríbete en Podemos")
  end

  context "when user is registered in census" do
    let(:user) { create(:user, :confirmed, :with_person, organization: organization) }

    it "invites user to verify its identity" do
      expect(subject).to have_text("Verifica tu identidad")
    end
  end

  context "when user is a member" do
    let(:user) { create(:user, :confirmed, :with_member_person, organization: organization) }

    it "invites user to participate" do
      expect(subject).to have_text("Descubre nuevas formas de participar en Podemos")
    end
  end
end
