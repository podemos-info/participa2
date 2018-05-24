# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        class MembershipLevelForm < Decidim::Form
          attribute :membership_level, Symbol

          def self.membership_levels
            Person.membership_levels
          end
        end
      end
    end
  end
end