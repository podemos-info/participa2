# frozen_string_literal: true

# This migration comes from decidim_collaborations (originally 20171128140711)

class AddLastOrderRequestDateToDecidimCollaborationsUserCollaboration < ActiveRecord::Migration[5.1]
  class UserCollaboration < ApplicationRecord
    self.table_name = :decidim_collaborations_user_collaborations
  end

  def change
    add_column :decidim_collaborations_user_collaborations, :last_order_request_date, :date

    UserCollaboration.find_each do |collaboration|
      collaboration.update(last_order_request_date: collaboration.created_at.beginning_of_month)
    end
  end
end
