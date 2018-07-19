# frozen_string_literal: true

module Decidim
  module Votings
    # Exposes votings to users.
    class VotesController < Decidim::Votings::ApplicationController
      helper_method :voting, :voting_identifier

      helper VotingsHelper

      def show
        raise ActionController::RoutingError, "Not Found" if voting.simulating? && params[:key] != voting.simulation_key

        enforce_permission_to voting_action, :voting, voting: voting
        render layout: "layouts/decidim/booth"
      end

      def token
        if voting.finished?
          flash[:error] = I18n.t("decidim.votings.messages.finished")
          render(plain: destination_url(voting), status: :gone) && return
        end

        enforce_permission_to voting_action, :voting, voting: voting
        attributes = { voting: voting, user: current_user }
        attributes[:simulated_code] = voting.simulated_code if voting.simulating_vote?
        vote = voting.vote_class.find_or_create_by(attributes)

        render plain: vote.token, status: :ok
      end

      private

      def voting_action
        voting.simulating? ? :simulate_vote : :vote
      end

      def voting
        @voting ||= Voting.find(params[:voting_id])
      end

      def destination_url(voting)
        voting.started? ? voting_url(voting.id) : voting_url(voting.id, key: voting.simulation_key)
      end

      def voting_identifier
        @voting_identifier ||= voting.voting_identifier_for(user_scope)
      end

      def user_scope
        @user_scope ||= Decidim::Votings.scope_resolver.call(current_user, voting)
      end
    end
  end
end
