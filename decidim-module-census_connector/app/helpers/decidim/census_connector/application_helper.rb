# frozen_string_literal: true

module Decidim
  module CensusConnector
    # Custom helpers, scoped to the census_connector engine.
    #
    module ApplicationHelper
      def unicode_options_sort(collection)
        collection.sort_by { |text, _| ActiveSupport::Inflector.transliterate(text) }
      end
    end
  end
end
