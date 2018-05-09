# This migration comes from decidim_votings (originally 20171129102752)
# frozen_string_literal: true

class CreateDecidimVotingsVotes < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_votings_votes do |t|
      t.references :decidim_user, foreign_key: true
      t.references :decidim_votings_voting, foreign_key: true
      t.integer :status, default: 0
      t.string :voter_identifier
      t.timestamps
    end
  end
end
