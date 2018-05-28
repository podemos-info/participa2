# frozen_string_literal: true

module Decidim
  module Votings
    module VoteConfirmation
      # This controller is the abstract class from which all other controllers of
      # the user profile inherit.
      #
      # Note that it inherits from `Decidim::ApplicationController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < ::ApplicationController
      end
    end
  end
end
