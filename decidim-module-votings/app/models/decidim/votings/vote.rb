# frozen_string_literal: true

module Decidim
  module Votings
    class Vote < Decidim::Votings::ApplicationRecord
      upsert_keys [:decidim_user_id, :decidim_votings_voting_id]

      belongs_to :voting, class_name: "Decidim::Votings::Voting", foreign_key: "decidim_votings_voting_id", inverse_of: :votes

      belongs_to :user, class_name: "Decidim::User", foreign_key: "decidim_user_id", inverse_of: false

      enum status: { pending: 0, confirmed: 1 }

      scope :by_user, ->(user) { where(decidim_user_id: user) }

      before_create :generate_voter_identifier

      def token
        raise "Vote should be saved before used" unless voter_identifier

        "#{message_hash}/#{message}"
      end

      protected

      def voter_identifier_key
        "#{Rails.application.secrets.secret_key_base}:#{user.id}:#{voting.id}"
      end

      private

      def message_hash
        @message_hash ||= OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new("sha256"), voting.shared_key, message)
      end

      def message
        @message ||= "#{voter_identifier}:AuthEvent:#{voting_identifier}:vote:#{Time.now.to_i}"
      end

      def generate_voter_identifier
        self.voter_identifier = Digest::SHA256.hexdigest(voter_identifier_key)
      end
    end
  end
end
