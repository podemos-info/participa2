# frozen_string_literal: true

module Decidim
  module Votings
    # Exposes votings to users.
    class VotingsController < Decidim::Votings::ApplicationController
      include FilterResource

      helper_method :voting, :has_voted?
      helper Decidim::PaginateHelper
      helper Decidim::ParticipatoryProcesses::ParticipatoryProcessHelper

      def index
        @votings = Voting.for_component(current_component).active_range(Decidim::Votings.upcoming_hours.hours, Decidim::Votings.closed_hours.hours).order_by_importance
      end

      def show; end

      private

      def voting
        @voting ||= Voting.find(params[:id])
      end

      def has_voted?
        @has_voted ||= voting.has_voted?(current_user)
      end
    end
  end
end
