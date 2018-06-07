# frozen_string_literal: true

# This migration comes from decidim_collaborations (originally 20171116140837)

class InitializeCollaborationAmounts < ActiveRecord::Migration[5.1]
  class Collaboration < ApplicationRecord
    self.table_name = :decidim_collaborations_collaborations
  end

  def change
    Collaboration.find_each do |collaboration|
      collaboration.amounts = Decidim::Collaborations.selectable_amounts
      collaboration.save
    end
  end
end
