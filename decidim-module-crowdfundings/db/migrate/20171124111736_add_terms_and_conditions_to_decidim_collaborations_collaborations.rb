# frozen_string_literal: true

class AddTermsAndConditionsToDecidimCollaborationsCollaborations < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_collaborations_collaborations, :terms_and_conditions, :jsonb
  end
end
