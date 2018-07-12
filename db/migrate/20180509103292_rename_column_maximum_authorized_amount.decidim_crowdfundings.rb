# frozen_string_literal: true

# This migration comes from decidim_crowdfundings (originally 20171110090236)

class RenameColumnMaximumAuthorizedAmount < ActiveRecord::Migration[5.1]
  def change
    rename_column :decidim_crowdfundings_campaigns, :maximum_authorized_amount, :minimum_custom_amount
  end
end
