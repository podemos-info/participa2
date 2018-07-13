# frozen_string_literal: true

class AddLastOrderRequestDateToDecidimCrowdfundingsContributions < ActiveRecord::Migration[5.1]
  class Contribution < ApplicationRecord
    self.table_name = :decidim_crowdfundings_contributions
  end

  def change
    add_column :decidim_crowdfundings_contributions, :last_order_request_date, :date

    Contribution.find_each do |contribution|
      contribution.update(last_order_request_date: contribution.created_at.beginning_of_month)
    end
  end
end
