# frozen_string_literal: true

# This migration comes from decidim_votings (originally 20180725101350)

class AddVotingIdentifierToDecidimVotingsVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_votings_votes, :voting_identifier, :string
    add_column :decidim_votings_simulated_votes, :voting_identifier, :string
  end
end
