# frozen_string_literal: true

require "rails_helper"

require "decidim/census_connector/test/factories"
require "decidim/crowdfundings/test/factories"
require "decidim/votings/test/factories"

describe ContentBlocks::HighlightedCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  around do |example|
    VCR.use_cassette(cassette, {}, &example)
  end

  controller Decidim::PagesController

  let(:organization) { create(:organization) }
  let(:content_block) { create :content_block, organization: organization, manifest_name: :highlighted, scope: :homepage, settings: settings }
  let(:settings) { {} }
  let(:current_user) { create :user, organization: organization }
  let(:cassette) { "" }

  before do
    allow(controller).to receive(:current_organization).and_return(organization)
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  it "is empty" do
    expect(subject.text).to be_empty
  end

  context "when has an assembly with a crowdfunding campaign" do
    let(:manifest) { Decidim.find_component_manifest("crowdfundings") }
    let!(:campaign) { create(:campaign, :assembly, reference: "I-CAMP-2019-08-30") }
    let(:cassette) { "crowdfunding_campaign" }

    it "shows the name of the space and a link to it" do
      expect(subject).to have_text(translated(campaign.component.participatory_space.title))
      expect(subject).to have_text("Visitar el espacio")
    end

    it "shows the campaign title and a support button" do
      expect(subject).to have_text(translated(campaign.title))
      expect(subject).to have_text("Apoyar")
    end
  end

  context "when has an assembly with an active voting" do
    let(:manifest) { Decidim.find_component_manifest("votings") }
    let!(:voting) { create(:voting, :n_votes, :assembly) }
    let(:cassette) { "voting" }

    it "shows the name of the space and a link to it" do
      expect(subject).to have_text(translated(voting.component.participatory_space.title))
      expect(subject).to have_text("Visitar el espacio")
    end

    it "shows the voting title and a vote button" do
      expect(subject).to have_text(translated(voting.title))
      expect(subject).to have_text("Votar")
    end
  end
end
