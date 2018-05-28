# frozen_string_literal: true

class AddHiddenToDecidimGravityForms < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_gravity_forms_gravity_forms, :hidden, :boolean, default: false, null: false
  end
end
