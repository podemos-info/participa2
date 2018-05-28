# frozen_string_literal: true

module Decidim
  module Collaborations
    # Base active record class for all models in Decidim Collaborations
    # engine.
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
