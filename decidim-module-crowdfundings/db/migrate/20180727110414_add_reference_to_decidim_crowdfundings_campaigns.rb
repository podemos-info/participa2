# frozen_string_literal: true

class AddReferenceToDecidimCrowdfundingsCampaigns < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_crowdfundings_campaigns, :reference, :string
  end
end
