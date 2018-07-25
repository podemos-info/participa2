# frozen_string_literal: true

module Decidim
  module Votings
    # Exposes votings to users.
    class VotesController < Decidim::Votings::ApplicationController
      before_action :enforce_can_vote

      helper_method :voting, :voting_identifier, :action_token_path
      helper VotingsHelper
      include Decidim::ResourceHelper

      def show
        redirect_to(action_voting_url) && return if flash[:error]

        render layout: "layouts/decidim/booth"
      end

      def token
        render(plain: action_voting_url, status: :gone) && return if flash[:error]

        attributes = { voting: voting, user: current_user, voting_identifier: voting_identifier }
        attributes[:simulation_code] = voting.simulation_code if voting.simulating?
        vote = voting.vote_class.find_or_create_by(attributes)

        render plain: vote.token, status: :ok
      end

      private

      def enforce_can_vote
        if voting.simulating? && params[:key] != voting.simulation_key
          flash[:error] = I18n.t("decidim.votings.messages.not_started")
        elsif voting.finished?
          flash[:error] = I18n.t("decidim.votings.messages.finished")
        elsif !allowed_to?(voting_action, :voting, voting: voting)
          flash[:error] = I18n.t("decidim.core.actions.unauthorized")
        end
      end

      def voting_action
        voting.simulating? ? :simulate_vote : :vote
      end

      def voting
        @voting ||= Voting.find(params[:voting_id])
      end

      def voting_identifier
        @voting_identifier ||= voting.voting_identifier_for(user_scope)
      end

      def action_voting_url
        @action_voting_url ||= resource_locator(voting).url(**simulation_params)
      end

      def action_token_path
        @token_path ||= token_voting_vote_path(voting.id, **simulation_params)
      end

      def user_scope
        @user_scope ||= Decidim::Votings.scope_resolver.call(current_user, voting)
      end

      def simulation_params
        @simulation_params ||= voting.simulating? ? { key: voting.simulation_key } : {}
      end
    end
  end
end
