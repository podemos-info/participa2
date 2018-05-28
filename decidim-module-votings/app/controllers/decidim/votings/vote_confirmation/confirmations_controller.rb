# frozen_string_literal: true

module Decidim
  module Votings
    module VoteConfirmation
      class ConfirmationsController < Decidim::Votings::VoteConfirmation::ApplicationController
        def confirm
          voter_id = params[:voter_id]
          vote = Vote.find_by(voter_identifier: voter_id) || SimulatedVote.find_by(voter_identifier: voter_id)
          vote.confirm! if vote && vote.voting&.voting_identifier == params[:election_id]
          render json: { result: "ok" }
        end
      end
    end
  end
end
