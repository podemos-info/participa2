# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      class VotesController < Decidim::Votings::Admin::ApplicationController
        def index
          send_data uniq_voter_ids.join("\n")
        end

        private

        def voting
          @voting ||= Voting.find(params[:voting_id])
        end

        def uniq_voter_ids
          @uniq_voter_ids ||= voting.target_votes
                                    .pluck(:voter_identifier, :voting_identifier, :decidim_user_id)
                                    .map { |vote| vote.join("\t") }
        end
      end
    end
  end
end
