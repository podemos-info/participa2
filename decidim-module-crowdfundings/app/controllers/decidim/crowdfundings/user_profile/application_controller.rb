# frozen_string_literal: true

module Decidim
  module Crowdfundings
    module UserProfile
      # This controller is the abstract class from which all other controllers of
      # the user profile inherit.
      #
      # Note that it inherits from `Decidim::ApplicationController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::ApplicationController
        include CensusPaymentsContext
        include Decidim::UserProfile
        include FormFactory

        helper Decidim::Crowdfundings::CampaignsHelper
        helper Decidim::Admin::IconLinkHelper
      end
    end
  end
end
