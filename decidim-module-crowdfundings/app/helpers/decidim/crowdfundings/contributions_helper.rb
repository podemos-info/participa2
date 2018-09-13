# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Helper methods for contributions controller views.
    module ContributionsHelper
      def state_label(contribution_state)
        I18n.t("labels.contribution.states.#{contribution_state}", scope: "decidim.crowdfundings")
      end
    end
  end
end
