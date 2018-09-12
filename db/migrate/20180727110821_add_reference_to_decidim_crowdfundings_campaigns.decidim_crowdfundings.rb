# frozen_string_literal: true

# This migration comes from decidim_crowdfundings (originally 20180727110414)

class AddReferenceToDecidimCrowdfundingsCampaigns < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_crowdfundings_campaigns, :reference, :string
  end
end
