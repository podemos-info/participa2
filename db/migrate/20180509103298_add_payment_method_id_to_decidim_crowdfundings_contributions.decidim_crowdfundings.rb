# frozen_string_literal: true

# This migration comes from decidim_crowdfundings (originally 20171120131908)

class AddPaymentMethodIdToDecidimCrowdfundingsContributions < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_crowdfundings_contributions, :payment_method_id, :integer
  end
end
