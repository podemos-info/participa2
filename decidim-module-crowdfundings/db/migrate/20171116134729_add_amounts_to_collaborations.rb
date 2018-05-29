# frozen_string_literal: true

class AddAmountsToCollaborations < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_collaborations_collaborations, :amounts, :jsonb
  end
end
