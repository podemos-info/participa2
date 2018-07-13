# frozen_string_literal: true

# This migration comes from decidim_crowdfundings (originally 20171116134729)

class AddAmountsToCampaigns < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_crowdfundings_campaigns, :amounts, :jsonb
  end
end
