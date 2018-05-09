# This migration comes from decidim_votings (originally 20171211163536)
# frozen_string_literal: true

class AddIndexesForVotes < ActiveRecord::Migration[5.1]
  def change
    add_index :decidim_votings_votes, [:decidim_votings_voting_id, :decidim_user_id], name: "idx_votes_voting_user", unique: true
    add_index :decidim_votings_simulated_votes, [:decidim_votings_voting_id, :decidim_user_id, :simulation_code], name: "idx_simulated_votes_voting_user_code", unique: true
  end
end
