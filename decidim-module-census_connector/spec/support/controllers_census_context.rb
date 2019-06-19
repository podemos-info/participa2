# frozen_string_literal: true

class DecidimController < ApplicationController
  include Decidim::CensusConnector::CensusContext
end
