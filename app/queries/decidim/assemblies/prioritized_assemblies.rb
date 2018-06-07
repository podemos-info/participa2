# frozen_string_literal: true

module Decidim
  module Assemblies
    # This query orders assemblies by importance and name, prioritizing promoted
    # assemblies and filtering child assemblies.
    class PrioritizedAssemblies < Rectify::Query
      def query
        Decidim::Assembly.where(parent: nil).order(promoted: :desc, title: :asc)
      end
    end
  end
end
