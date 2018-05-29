# frozen_string_literal: true

require "spec_helper"

describe "Admin manages votings", type: :system, serves_map: true do
  let(:manifest_name) { "votings" }
  let!(:voting) { create :voting, component: current_component, voting_system: "nVotes" }

  include_context "when managing a component as an admin"

  it_behaves_like "manage votings"
end
