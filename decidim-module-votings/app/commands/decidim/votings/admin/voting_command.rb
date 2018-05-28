# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This command contains all common methods for all voting related
      # commands
      class VotingCommand < Rectify::Command
        attr_reader :form

        def initialize(form)
          @form = form
        end
      end
    end
  end
end
