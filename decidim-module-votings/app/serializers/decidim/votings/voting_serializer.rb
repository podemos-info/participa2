# frozen_string_literal: true

require "active_model_serializers"
module Decidim
  module Votings
    class VotingSerializer < ActiveModel::Serializer
      attributes :id, :start_date, :end_date, :census_date_limit, :voting_identifier, :created_at
    end
  end
end
