# frozen_string_literal: true

# This migration comes from decidim_crowdfundings (originally 20171129083613)

class RemoveTotalCollectedFromDecidimCrowdfundingsCampaigns < ActiveRecord::Migration[5.1]
  def change
    remove_column :decidim_crowdfundings_campaigns,
                  :total_collected,
                  :decimal,
                  precission: 11,
                  scale: 2
  end
end
