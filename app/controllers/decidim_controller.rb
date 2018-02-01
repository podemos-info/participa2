# frozen_string_literal: true

# Entry point for Decidim. It will use the `DecidimController` as
# entry point, but you can change what controller it inherits from
# so you can customize some methods.
class DecidimController < ApplicationController
  include Decidim::CensusConnector::CensusContext

  helper Decidim::Collaborations::CollaborationsHelper
  helper Decidim::Collaborations::TotalsHelper
end
