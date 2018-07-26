# frozen_string_literal: true

module Decidim
  module Votings
    class SimulatedVote < Decidim::Votings::Vote
      self.table_name = "decidim_votings_simulated_votes"
      upsert_keys [:decidim_user_id, :decidim_votings_voting_id, :simulation_code]

      scope :by_simulation_code, ->(simulation_code) { where(simulation_code: simulation_code) }

      protected

      def voter_identifier_key
        "#{super}:#{simulation_code}"
      end
    end
  end
end
