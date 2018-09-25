# frozen_string_literal: true

module Decidim
  module CensusConnector
    # The main application controller that inherits from Decidim base controller.
    class ApplicationController < ::Decidim::ApplicationController
      include CensusContext

      helper Decidim::CensusConnector::ApplicationHelper
    end
  end
end
