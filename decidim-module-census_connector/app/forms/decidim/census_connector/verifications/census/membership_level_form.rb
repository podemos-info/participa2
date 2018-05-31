# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        class MembershipLevelForm < Decidim::Form
          attribute :level, Symbol
        end
      end
    end
  end
end
