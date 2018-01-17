# This migration comes from decidim_votings (originally 20171205104430)
# frozen_string_literal: true

class CreateDecidimVotingsSimulatedVotes < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_votings_simulated_votes do |t|
      t.references :decidim_user, foreign_key: true
      t.references :decidim_votings_voting, foreign_key: true, index: { name: "index_simulated_votes_on_voting" }
      t.integer :status, default: 0
      t.string :voter_identifier
      t.timestamps
    end
  end
end
