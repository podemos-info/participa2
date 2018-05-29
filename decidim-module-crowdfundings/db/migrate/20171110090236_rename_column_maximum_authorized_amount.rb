# frozen_string_literal: true

class RenameColumnMaximumAuthorizedAmount < ActiveRecord::Migration[5.1]
  def change
    rename_column :decidim_collaborations_collaborations, :maximum_authorized_amount, :minimum_custom_amount
  end
end
