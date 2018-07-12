# frozen_string_literal: true

class RemoveTotalCollectedFromDecidimCrowdfundingsCampaigns < ActiveRecord::Migration[5.1]
  def change
    remove_column :decidim_crowdfundings_campaigns,
                  :total_collected,
                  :decimal,
                  precission: 11,
                  scale: 2
  end
end
