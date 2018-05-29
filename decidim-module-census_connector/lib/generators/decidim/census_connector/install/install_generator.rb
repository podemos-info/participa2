# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Generators
      class InstallGenerator < ::Rails::Generators::Base
        desc <<~DESC
          Description:
            Install census connector into a decidim application.
        DESC

        def self.source_root
          @source_root ||= File.expand_path("templates", __dir__)
        end

        def copy_configuration
          template "config/initializers/decidim-census_connector.rb"
        end
      end
    end
  end
end
