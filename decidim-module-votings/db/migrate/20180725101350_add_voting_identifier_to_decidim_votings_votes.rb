# frozen_string_literal: true

class AddVotingIdentifierToDecidimVotingsVotes < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_votings_votes, :voting_identifier, :string
    add_column :decidim_votings_simulated_votes, :voting_identifier, :string
  end
end
