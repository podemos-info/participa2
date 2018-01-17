# This migration comes from decidim_votings (originally 20171128124013)
class ChangeVotingDatesToDatetimes < ActiveRecord::Migration[5.1]
  def up
    change_column :decidim_votings_votings, :start_date, :datetime
    change_column :decidim_votings_votings, :end_date, :datetime
    change_column :decidim_votings_votings, :census_date_limit, :datetime
  end

  def down
    change_column :decidim_votings_votings, :start_date, :date
    change_column :decidim_votings_votings, :end_date, :date
    change_column :decidim_votings_votings, :census_date_limit, :date
  end

end
