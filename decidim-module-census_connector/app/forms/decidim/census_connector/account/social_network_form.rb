# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Account
      class SocialNetworkForm < DeleteSocialNetworkForm
        attribute :nickname, String

        def self.social_networks_options
          @social_networks_options ||= Decidim::CensusConnector.social_networks.map do |social_network, info|
            [info[:name], social_network]
          end.freeze
        end

        validates :network, inclusion: { in: Decidim::CensusConnector.social_networks.keys.map(&:to_s) }
        validates :nickname, presence: true

        validate :nickname_format

        def reset
          @network = @nickname = @nickname_match = nil
        end

        def nickname
          return nickname_match[1] if nickname_validator && nickname_match

          super
        end

        private

        def nickname_format
          errors.add(:nickname, :invalid) if nickname_validator && !nickname_validator.match?(@nickname)
        end

        def nickname_validator
          @nickname_validator ||= begin
            pattern = Decidim::CensusConnector.social_networks.dig(network.to_sym, :nickname_validation) if network
            /#{pattern}/ if pattern
          end
        end

        def nickname_match
          @nickname_match ||= nickname_validator.match(@nickname)
        end
      end
    end
  end
end
