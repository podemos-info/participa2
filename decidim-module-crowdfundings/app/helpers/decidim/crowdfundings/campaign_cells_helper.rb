# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Custom helpers used in campaign cells
    module CampaignCellsHelper
      include ActionView::Helpers::NumberHelper
      include TranslatableAttributes
      include CampaignsHelper
      include TotalsHelper
    end
  end
end
