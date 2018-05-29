# frozen_string_literal: true

module Decidim
  module Votings
    class Vote < Decidim::Votings::ApplicationRecord
      belongs_to :voting, class_name: "Decidim::Votings::Voting", foreign_key: "decidim_votings_voting_id", inverse_of: :votes

      belongs_to :user, class_name: "Decidim::User", foreign_key: "decidim_user_id", inverse_of: false

      enum status: { pending: 0, confirmed: 1 }

      scope :for_voting, ->(voting) { where(decidim_votings_voting_id: voting) }
      scope :by_user, ->(user) { where(decidim_user_id: user) }

      before_create :ensure_voter_identifier

      def token
        message = generate_message
        "#{generate_hash message}/#{message}"
      end

      def generate_message
        "#{voter_id}:AuthEvent:#{voting.voting_identifier}:vote:#{Time.now.to_i}"
      end

      def generate_hash(message)
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA256.new("sha256"), voting.shared_key, message)
      end

      def confirm!
        update(status: "confirmed")
      end

      private

      def ensure_voter_identifier
        self.voter_identifier = voter_id if voter_identifier.blank?
      end

      def voter_id
        Digest::SHA256.hexdigest("#{Rails.application.secrets.secret_key_base}:#{user.id}:#{voting.id}:#{Time.current}")
      end
    end
  end
end
