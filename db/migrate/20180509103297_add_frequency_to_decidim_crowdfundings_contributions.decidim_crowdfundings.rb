# frozen_string_literal: true

# This migration comes from decidim_crowdfundings (originally 20171117122508)

class AddFrequencyToDecidimCrowdfundingsContributions < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_crowdfundings_contributions,
               :frequency,
               :integer,
               null: false,
               default: 0,
               index: { name: "contribution_frequency_index" }
  end
end
