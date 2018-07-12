# frozen_string_literal: true

module Decidim
  module Crowdfundings
    class PersonPrioritizedCampaigns < Rectify::Query
      def initialize(person_participatory_spaces)
        @person_participatory_spaces = person_participatory_spaces
      end

      def query
        Decidim::Crowdfundings::Campaign.joins(:component).merge(
          Decidim::Component.published.where(
            manifest_name: "crowdfundings",
            participatory_space: @person_participatory_spaces
          )
        )
      end
    end
  end
end
