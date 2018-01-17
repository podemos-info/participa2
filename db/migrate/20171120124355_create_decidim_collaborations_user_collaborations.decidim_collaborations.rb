# This migration comes from decidim_collaborations (originally 20171113105218)
class CreateDecidimCollaborationsUserCollaborations < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_collaborations_user_collaborations do |t|
      t.references :decidim_user, index: { name: 'user_colaboration_user_idx' }
      t.references :decidim_collaborations_collaboration,
                   index: { name: 'user_collaboration_collaboration_idx' }
      t.decimal :amount, precision: 11, scale: 2, null: false
      t.integer :state, null: false, index: true

      t.timestamps
    end
  end
end
