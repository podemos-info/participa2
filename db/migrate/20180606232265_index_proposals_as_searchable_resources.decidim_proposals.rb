# frozen_string_literal: true

# This migration comes from decidim_proposals (originally 20180516131201)

class IndexProposalsAsSearchableResources < ActiveRecord::Migration[5.1]
  class Proposal < ApplicationRecord
    self.table_name = :decidim_proposals_proposals

    include Decidim::Searchable
    include Decidim::HasComponent

    searchable_fields(
      scope_id: :decidim_scope_id,
      participatory_space: { component: :participatory_space },
      A: :title,
      D: :body,
      datetime: :published_at
    )
  end

  def up
    Proposal.find_each(&:add_to_index_as_search_resource)
  end

  def down
    Decidim::SearchableResource.where(resource_type: "Decidim::Proposals::Proposal").destroy_all
  end
end
