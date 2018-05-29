# frozen_string_literal: true

require "spec_helper"

describe "Admin manages collaborations", type: :system, serves_map: true do
  let(:manifest_name) { "collaborations" }
  let!(:collaboration) { create :collaboration, component: current_component }

  before do
    stub_totals_request(500)
  end

  include_context "when managing a component as an admin"

  it_behaves_like "manage collaborations"
end
