# frozen_string_literal: true

class AddFrequencyToDecidimCollaborationsUserCollaborations < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_collaborations_user_collaborations,
               :frequency,
               :integer,
               null: false,
               default: 0,
               index: { name: "user_collaboration_frequency_index" }
  end
end
