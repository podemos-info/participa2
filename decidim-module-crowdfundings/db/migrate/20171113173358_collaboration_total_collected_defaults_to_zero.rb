# frozen_string_literal: true

class CollaborationTotalCollectedDefaultsToZero < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      dir.up do
        change_column :decidim_collaborations_collaborations,
                      :total_collected,
                      :decimal,
                      precision: 11,
                      scale: 2,
                      null: false,
                      default: 0
      end

      dir.down do
        change_column :decidim_collaborations_collaborations,
                      :total_collected,
                      :decimal,
                      precision: 11,
                      scale: 2,
                      null: true
      end
    end
  end
end
