# frozen_string_literal: true

module Decidim
  module Votings
    module VoteConfirmation
      class ConfirmationsController < Decidim::Votings::VoteConfirmation::ApplicationController
        skip_before_action :verify_authenticity_token

        def confirm
          Decidim::Votings::ConfirmVote.call(voting_identifier: params[:voting_identifier], voter_identifier: params[:voter_identifier]) do
            on(:ok) do
              render json: { result: "ok" }
            end
            on(:invalid) do
              render json: { result: "error" }
            end
          end
        end
      end
    end
  end
end
