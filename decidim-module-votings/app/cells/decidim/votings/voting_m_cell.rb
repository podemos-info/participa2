# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Votings
    # This cell renders a voting with its M-size card.
    class VotingMCell < Decidim::CardMCell
      include VotingCellsHelper

      private

      def title
        translated_attribute model.title
      end

      def description
        translated_attribute model.description
      end
    end
  end
end
