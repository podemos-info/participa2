# This migration comes from decidim_collaborations (originally 20171129083613)
class RemoveTotalCollectedFromDecidimCollaborationsCollaborations < ActiveRecord::Migration[5.1]
  def change
    remove_column :decidim_collaborations_collaborations,
                  :total_collected,
                  :decimal,
                  precission: 11,
                  scale: 2
  end
end
