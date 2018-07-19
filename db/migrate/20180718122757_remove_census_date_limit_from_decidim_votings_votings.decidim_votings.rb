# frozen_string_literal: true
# This migration comes from decidim_votings (originally 20180718122607)

class RemoveCensusDateLimitFromDecidimVotingsVotings < ActiveRecord::Migration[5.2]
  def up
    remove_column :decidim_votings_votings, :census_date_limit
  end

  def down
    add_column :decidim_votings_votings, :census_date_limit, :datetime
  end
end
