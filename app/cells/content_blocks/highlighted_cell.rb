# frozen_string_literal: true

require "cell/partial"

module ContentBlocks
  class HighlightedCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include Decidim::ViewHooksHelper
    include Decidim::ComponentPathHelper

    delegate :current_user, :person_scopes, :person_participatory_spaces, :current_participatory_space, :with_participatory_space, to: :controller

    def process_options!(options)
      options[:formats] = [:html]
      super
    end
  end
end
