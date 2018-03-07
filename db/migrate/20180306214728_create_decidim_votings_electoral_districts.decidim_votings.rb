# This migration comes from decidim_votings (originally 20180301123833)
# frozen_string_literal: true

class CreateDecidimVotingsElectoralDistricts < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_votings_electoral_districts do |t|
      t.references :decidim_scope, foreign_key: true
      t.references :decidim_votings_voting, foreign_key: true, index: { name: :decidim_votings_electoral_distrings_on_voting_id }
      t.string :voting_identifier
    end
  end
end
