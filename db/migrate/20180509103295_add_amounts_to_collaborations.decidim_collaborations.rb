# This migration comes from decidim_collaborations (originally 20171116134729)
# frozen_string_literal: true

class AddAmountsToCollaborations < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_collaborations_collaborations, :amounts, :jsonb
  end
end
