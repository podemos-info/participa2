# frozen_string_literal: true

module Decidim
  module Votings
    class SimulatedVote < Decidim::Votings::Vote
      self.table_name = "decidim_votings_simulated_votes"

      scope :by_simulation_code, ->(simulation_code) { where(simulation_code: simulation_code) }
    end
  end
end
