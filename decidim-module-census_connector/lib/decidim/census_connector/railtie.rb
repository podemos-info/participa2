# frozen_string_literal: true

module Decidim
  module CensusConnector
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load "tasks/decidim_census_connector.rake"
      end
    end
  end
end
