# frozen_string_literal: true

require "cell/partial"

module ContentBlocks
  class HighlightedCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include Decidim::ViewHooksHelper
    include Decidim::ComponentPathHelper

    delegate :current_user, :person_scopes, :current_participatory_space, :with_participatory_space, to: :controller

    def person_participatory_spaces
      @person_participatory_spaces ||= Decidim.participatory_space_registry.manifests.flat_map do |participatory_space_manifest|
        participatory_space_model = participatory_space_manifest.model_class_name.constantize
        next unless participatory_space_model.columns_hash["decidim_scope_id"]
        participatory_space_model.published.where(decidim_scope_id: person_scopes)
      end.compact.sort_by(&:id)
    end

    def process_options!(options)
      options[:formats] = [:html]
      super
    end
  end
end
