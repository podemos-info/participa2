# frozen_string_literal: true

# This migration comes from decidim_crowdfundings (originally 20171124111736)

class AddTermsAndConditionsToDecidimCrowdfundingsCampaigns < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_crowdfundings_campaigns, :terms_and_conditions, :jsonb
  end
end
