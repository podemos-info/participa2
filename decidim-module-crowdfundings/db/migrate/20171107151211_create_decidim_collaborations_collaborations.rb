# frozen_string_literal: true

class CreateDecidimCollaborationsCollaborations < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_collaborations_collaborations do |t|
      t.jsonb :title
      t.jsonb :description
      t.integer :default_amount
      t.integer :maximum_authorized_amount
      t.integer :target_amount
      t.decimal :total_collected, precision: 11, scale: 2
      t.date :active_until
      t.references :decidim_component, index: { name: "decidim_colaborations_component_index" }

      t.timestamps
    end
  end
end
