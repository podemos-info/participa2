# frozen_string_literal: true

require "spec_helper"

describe "Admin manages crowdfundings campaigns", type: :system, serves_map: true do
  let(:manifest_name) { "crowdfundings" }
  let!(:campaign) { create :campaign, component: current_component }

  before do
    stub_totals_request(500)
  end

  include_context "when managing a component as an admin"

  it_behaves_like "manage crowdfunding campaigns"
end
