# frozen_string_literal: true

# This migration comes from decidim_crowdfundings (originally 20171113173358)

class CampaignTotalCollectedDefaultsToZero < ActiveRecord::Migration[5.1]
  def change
    reversible do |dir|
      dir.up do
        change_column :decidim_crowdfundings_campaigns,
                      :total_collected,
                      :decimal,
                      precision: 11,
                      scale: 2,
                      null: false,
                      default: 0
      end

      dir.down do
        change_column :decidim_crowdfundings_campaigns,
                      :total_collected,
                      :decimal,
                      precision: 11,
                      scale: 2,
                      null: true
      end
    end
  end
end
