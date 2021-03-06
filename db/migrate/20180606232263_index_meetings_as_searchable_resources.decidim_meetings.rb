# frozen_string_literal: true

# This migration comes from decidim_meetings (originally 20180516102301)

class IndexMeetingsAsSearchableResources < ActiveRecord::Migration[5.1]
  class Meeting < ApplicationRecord
    self.table_name = :decidim_meetings_meetings

    include Decidim::Searchable
    include Decidim::HasComponent

    searchable_fields(
      scope_id: :decidim_scope_id,
      participatory_space: { component: :participatory_space },
      A: :title,
      D: [:description, :address],
      datetime: :start_time
    )
  end

  def up
    Meeting.find_each(&:add_to_index_as_search_resource)
  end

  def down
    Decidim::SearchableResource.where(resource_type: "Decidim::Meetings::Meeting").destroy_all
  end
end
