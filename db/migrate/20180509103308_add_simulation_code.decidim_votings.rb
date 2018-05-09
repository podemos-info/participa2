# This migration comes from decidim_votings (originally 20171211143945)
# frozen_string_literal: true

class AddSimulationCode < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_votings_simulated_votes, :simulation_code, :integer, null: false, default: 0
    add_column :decidim_votings_votings, :simulation_code, :integer, null: false, default: 0
  end
end
