# frozen_string_literal: true

require "rails"
require "active_support/all"

require "decidim/core"

module Decidim
  module Votings
    # Decidim's <EngineName> Rails Engine.
    class VoteConfirmationEngine < ::Rails::Engine
      isolate_namespace Decidim::Votings::VoteConfirmation
      paths["db/migrate"] = nil

      routes do
        get "confirm/:election_id/:voter_id", action: :confirm, controller: "confirmations"
      end
    end
  end
end
