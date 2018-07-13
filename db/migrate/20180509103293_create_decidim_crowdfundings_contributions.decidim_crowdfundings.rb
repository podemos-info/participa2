# frozen_string_literal: true

# This migration comes from decidim_crowdfundings (originally 20171113105218)

class CreateDecidimCrowdfundingsContributions < ActiveRecord::Migration[5.1]
  def change
    create_table :decidim_crowdfundings_contributions do |t|
      t.references :decidim_user, index: { name: "contributions_user_idx" }
      t.references :decidim_crowdfundings_campaign,
                   index: { name: "contribution_campaign_idx" }
      t.decimal :amount, precision: 11, scale: 2, null: false
      t.integer :state, null: false, index: true

      t.timestamps
    end
  end
end
