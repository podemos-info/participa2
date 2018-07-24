# frozen_string_literal: true

require "decidim/votings/admin"
require "decidim/votings/admin_engine"
require "decidim/votings/engine"
require "decidim/votings/vote_confirmation"
require "decidim/votings/vote_confirmation_engine"
require "decidim/votings/component"

module Decidim
  module Votings
    include ActiveSupport::Configurable
    # Number of collaborations shown per page in administrator
    # dashboard
    config_accessor :votings_shown_per_page do
      15
    end

    # Number of hours to show a voting before it starts
    config_accessor :upcoming_hours do
      24
    end

    # Number of hours to show a voting after it ended
    config_accessor :closed_hours do
      12
    end

    # A proc or a class implementing  a `call` method to return the scope for a
    # given user in a given voting
    config_accessor :scope_resolver do
      ->(_user, _voting) { nil }
    end

    # Public Setting that defines how many votings will be shown in the
    # participatory_space_highlighted_elements view hook
    config_accessor :participatory_space_highlighted_votings_limit do
      3
    end
  end
end
