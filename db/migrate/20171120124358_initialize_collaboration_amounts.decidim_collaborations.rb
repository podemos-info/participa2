# This migration comes from decidim_collaborations (originally 20171116140837)
class InitializeCollaborationAmounts < ActiveRecord::Migration[5.1]
  def change
    Decidim::Collaborations::Collaboration.find_each do |collaboration|
      collaboration.amounts = Decidim::Collaborations.selectable_amounts
      collaboration.save
    end
  end
end
