# frozen_string_literal: true

require "httparty"

module Decidim
  module Votings
    # Base class for all Census API classes
    class RemoteAuthorizer
      include ::HTTParty

      attr_accessor :url

      def initialize(url)
        self.url = url
      end

      def authorized?(user, voting)
        options = {
          body: {
            voting: Decidim::Votings::VotingSerializer.new(voting).as_json,
            user: Decidim::Votings::UserSerializer.new(user).as_json
          }
        }
        response = RemoteAuthorizer.post(url, options)
        response.code == 201
      end
    end
  end
end
