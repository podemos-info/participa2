# frozen_string_literal: true

module Decidim
  module Votings
    # Exposes votings to users.
    class VotingsController < Decidim::Votings::ApplicationController
      include FilterResource

      helper_method :voting
      helper Decidim::PaginateHelper
      helper Decidim::ParticipatoryProcesses::ParticipatoryProcessHelper

      def index
        @votings = Voting.for_component(current_component).topical.order_by_importance
      end

      def show; end

      private

      def voting
        @voting ||= Voting.find(params[:id])
      end
    end
  end
end
