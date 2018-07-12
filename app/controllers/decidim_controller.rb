# frozen_string_literal: true

# Entry point for Decidim. It will use the `DecidimController` as
# entry point, but you can change what controller it inherits from
# so you can customize some methods.
class DecidimController < ApplicationController
  include Decidim::CensusConnector::CensusContext

  helper Decidim::Crowdfundings::CampaignsHelper
  helper Decidim::Crowdfundings::TotalsHelper

  helper Decidim::ResourceReferenceHelper
  helper Decidim::ResourceHelper
  helper_method :current_participatory_space, :with_participatory_space

  def current_participatory_space
    @temp_participatory_space || request.env["decidim.current_participatory_space"]
  end

  def with_participatory_space(participatory_space)
    @temp_participatory_space = participatory_space
    yield
    @temp_participatory_space = nil
  end
end
