# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Account
      class DeleteSocialNetworkForm < Decidim::Form
        attribute :network, String

        validates :network, presence: true
      end
    end
  end
end
