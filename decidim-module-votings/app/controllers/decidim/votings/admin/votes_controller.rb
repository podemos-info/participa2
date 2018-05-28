# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      class VotesController < Decidim::Votings::Admin::ApplicationController
        def index
          @votes = voting.target_votes
          render "index", layout: false, formats: [:text]
        end

        private

        def voting
          @voting ||= Voting.find(params[:voting_id])
        end
      end
    end
  end
end
