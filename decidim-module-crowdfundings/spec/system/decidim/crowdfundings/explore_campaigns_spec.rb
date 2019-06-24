# frozen_string_literal: true

require "spec_helper"

describe "Explore campaigns", type: :system do
  include_context "with a component"
  let(:manifest_name) { "crowdfundings" }

  let(:campaigns_count) { 5 }
  let!(:campaigns) do
    create_list(:campaign, campaigns_count, component: component)
  end

  before do
    stub_orders_total(0)
  end

  describe "index" do
    it "shows all campaigns for the given process" do
      visit_component

      campaigns.each do |campaign|
        expect(page).to have_selector("#campaign-#{campaign.id}-item")
        expect(page).to have_content(translated(campaign.title))
      end
    end
  end

  describe "filtering" do
    it "allows searching by text" do
      visit_component

      within ".filters" do
        fill_in "filter[search_text]", with: translated(campaigns.first.title)

        # The form should be auto-submitted when filter box is filled up, but
        # somehow it's not happening. So we workaround that be explicitly
        # clicking on "Search" until we find out why.
        find(".icon--magnifying-glass").click
      end

      expect(page).to have_css(".card--list__item", count: 1)
      expect(page).to have_content(translated(campaigns.first.title))
    end
  end
end
