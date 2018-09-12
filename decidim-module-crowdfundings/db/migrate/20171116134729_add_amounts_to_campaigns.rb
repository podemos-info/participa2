# frozen_string_literal: true

class AddAmountsToCampaigns < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_crowdfundings_campaigns, :amounts, :jsonb
  end
end
