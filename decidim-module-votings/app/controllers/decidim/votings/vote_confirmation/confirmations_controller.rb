# frozen_string_literal: true

module Decidim
  module Votings
    module VoteConfirmation
      class ConfirmationsController < Decidim::Votings::VoteConfirmation::ApplicationController
        skip_before_action :verify_authenticity_token

        def confirm
          voter_id = params[:voter_id]
          vote = Vote.find_by(voter_identifier: voter_id) || SimulatedVote.find_by(voter_identifier: voter_id)
          if vote && vote.voting&.voting_identifier == params[:election_id]
            vote.confirm!
            render json: { result: "ok" }
            return
          end
          render json: { result: "error" }
        end
      end
    end
  end
end
