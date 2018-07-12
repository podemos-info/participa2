# frozen_string_literal: true

class AddPaymentMethodIdToDecidimCrowdfundingsContributions < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_crowdfundings_contributions, :payment_method_id, :integer
  end
end
