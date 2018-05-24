# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        class MembershipLevelHandler < Decidim::Form
          mimic :membership_level_handler

          attribute :membership_level, Symbol

          def self.membership_levels
            Person.membership_levels
          end
        end
      end
    end
  end
end
