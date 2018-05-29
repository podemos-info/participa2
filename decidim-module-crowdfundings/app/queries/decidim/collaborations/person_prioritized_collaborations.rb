# frozen_string_literal: true

module Decidim
  module Collaborations
    class PersonPrioritizedCollaborations < Rectify::Query
      def initialize(person_participatory_spaces)
        @person_participatory_spaces = person_participatory_spaces
      end

      def query
        Decidim::Collaborations::Collaboration.joins(:component).merge(
          Decidim::Component.published.where(
            manifest_name: "collaborations",
            participatory_space: @person_participatory_spaces
          )
        )
      end
    end
  end
end
