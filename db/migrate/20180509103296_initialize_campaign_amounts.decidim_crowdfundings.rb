# frozen_string_literal: true

# This migration comes from decidim_crowdfundings (originally 20171116140837)

class InitializeCampaignAmounts < ActiveRecord::Migration[5.1]
  class Campaign < ApplicationRecord
    self.table_name = :decidim_crowdfundings_campaigns
  end

  def change
    Campaign.find_each do |campaign|
      campaign.amounts = Decidim::Crowdfundings.selectable_amounts
      campaign.save
    end
  end
end
