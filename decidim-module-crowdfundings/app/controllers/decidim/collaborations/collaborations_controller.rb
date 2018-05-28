# frozen_string_literal: true

module Decidim
  module Collaborations
    # Exposes collaborations to users.
    class CollaborationsController < Decidim::Collaborations::ApplicationController
      include FilterResource
      include CensusAPI

      helper_method :collaborations, :random_seed
      helper Decidim::PaginateHelper
      helper Decidim::ParticipatoryProcesses::ParticipatoryProcessHelper

      include NeedsCollaboration

      def index
        return unless component_collaborations.count == 1

        redirect_to EngineRouter.main_proxy(current_component)
                                .collaboration_path(component_collaborations.first)
      end

      def show
        @form = user_collaboration_form.instance(collaboration: collaboration)
        initialize_form_defaults
      end

      private

      def initialize_form_defaults
        @form.amount = collaboration.default_amount
        @form.frequency = if collaboration.recurrent_support_allowed?
                            Decidim::Collaborations.default_frequency
                          else
                            "punctual"
                          end
      end

      def collaborations
        @collaborations ||= search
                            .results
                            .page(params[:page])
                            .per(Decidim::Collaborations.collaborations_shown_per_page)
      end

      def component_collaborations
        Collaboration.for_component(current_component)
      end

      def random_seed
        @random_seed ||= search.random_seed
      end

      def search_klass
        CollaborationSearch
      end

      def default_filter_params
        {
          search_text: "",
          random_seed: params[:random_seed]
        }
      end

      def context_params
        { component: current_component, organization: current_organization }
      end

      def user_collaboration_form
        form(Decidim::Collaborations::UserCollaborationForm)
      end
    end
  end
end
