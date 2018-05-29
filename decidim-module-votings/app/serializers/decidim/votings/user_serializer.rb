# frozen_string_literal: true

require "active_model_serializers"
module Decidim
  module Votings
    class UserSerializer < ActiveModel::Serializer
      attributes :id, :email, :name, :created_at
    end
  end
end
