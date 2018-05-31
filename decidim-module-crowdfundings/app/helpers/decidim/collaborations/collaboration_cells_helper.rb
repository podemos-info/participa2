# frozen_string_literal: true

module Decidim
  module Collaborations
    # Custom helpers used in meetings views
    module CollaborationCellsHelper
      include ActionView::Helpers::NumberHelper
      include TranslatableAttributes
      include CollaborationsHelper
      include TotalsHelper
    end
  end
end
