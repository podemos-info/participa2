# frozen_string_literal: true

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
