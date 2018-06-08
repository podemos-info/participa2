# frozen_string_literal: true

class AddSlugIndexToDecidimGravityForms < ActiveRecord::Migration[5.1]
  def change
    add_index :decidim_gravity_forms_gravity_forms,
              [:decidim_component_id, :slug],
              unique: true,
              name: "decidim_gravity_forms_gravity_forms_component_slug_unique"
  end
end
