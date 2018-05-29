# frozen_string_literal: true

class CreateDecidimVotingsVotings < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_votings_votings do |t|
      t.jsonb :title
      t.jsonb :description
      t.string :image
      t.date :start_date
      t.date :end_date
      t.integer :status, default: 0

      # Scopeable
      t.integer :decidim_scope_id, index: true

      t.date :census_date_limit
      t.integer :importance
      t.string :voting_system
      t.jsonb :system_configuration

      t.references :decidim_component, index: { name: "decidim_votings_component_index" }

      t.timestamps
    end
  end
end
