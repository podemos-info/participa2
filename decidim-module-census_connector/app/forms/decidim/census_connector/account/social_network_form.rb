# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Account
      class SocialNetworkForm < DeleteSocialNetworkForm
        attribute :nickname, String

        def self.social_networks_info
          @social_networks_info ||= Rails.application.secrets.social_networks
        end

        def self.social_networks_options
          @social_networks_options ||= social_networks_info.map do |social_network, info|
            [info[:name], social_network]
          end.freeze
        end

        validates :network, inclusion: { in: social_networks_info.keys.map(&:to_s) }
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
          if nickname_validator && !nickname_validator.match?(@nickname)
            errors.add(:nickname, :invalid_format)
          end
        end

        def nickname_validator
          @nickname_validator ||= begin
            pattern = self.class.social_networks_info.dig(network.to_sym, :nickname_validation) if network
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
