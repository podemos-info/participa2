# frozen_string_literal: true

module Decidim
  module Collaborations
    module Generators
      class InstallGenerator < ::Rails::Generators::Base
        desc <<~DESC
          Description:
            Install crowdfundings module into a decidim application.
        DESC

        def install_census_connector
          invoke "decidim:census_connector:install"
        end

        def enhance_decidim_controller
          inject_into_file "app/controllers/decidim_controller.rb",
                           after: "class DecidimController < ApplicationController\n" do
            <<~RUBY.gsub(/^ *\|/, "")
              |  include Decidim::CensusConnector::CensusContext

              |  helper Decidim::Collaborations::CollaborationsHelper
              |  helper Decidim::Collaborations::TotalsHelper
            RUBY
          end
        end
      end
    end
  end
end
