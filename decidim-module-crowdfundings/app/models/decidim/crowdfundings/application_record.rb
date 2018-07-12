# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Base active record class for all models in Decidim Crowdfundings
    # engine.
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
