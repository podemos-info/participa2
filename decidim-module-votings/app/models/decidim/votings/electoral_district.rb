# frozen_string_literal: true

module Decidim
  module Votings
    class ElectoralDistrict < Decidim::Votings::ApplicationRecord
      belongs_to :voting, foreign_key: :decidim_votings_voting_id
      belongs_to :scope, foreign_key: :decidim_scope_id
    end
  end
end
