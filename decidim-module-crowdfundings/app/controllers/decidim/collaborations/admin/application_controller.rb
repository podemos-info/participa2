# frozen_string_literal: true

module Decidim
  module Collaborations
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Components::BaseController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::Admin::Components::BaseController
        helper_method :collaborations, :collaboration
        helper Decidim::Collaborations::CollaborationsHelper

        def collaborations
          @collaborations ||= Collaboration
                              .for_component(current_component)
                              .page(params[:page])
                              .per(Decidim::Collaborations.collaborations_shown_per_page)
        end

        def collaboration
          @collaboration ||= collaborations.find(params[:id])
        end
      end
    end
  end
end
