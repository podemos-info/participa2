# This migration comes from decidim_collaborations (originally 20171124111736)
class AddTermsAndConditionsToDecidimCollaborationsCollaborations < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_collaborations_collaborations, :terms_and_conditions, :jsonb
  end
end
