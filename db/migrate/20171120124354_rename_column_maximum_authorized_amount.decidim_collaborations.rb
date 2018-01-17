# This migration comes from decidim_collaborations (originally 20171110090236)
class RenameColumnMaximumAuthorizedAmount < ActiveRecord::Migration[5.1]
  def change
    rename_column :decidim_collaborations_collaborations, :maximum_authorized_amount, :minimum_custom_amount
  end
end
