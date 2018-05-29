# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Abilities
        # Defines the abilities related to proposals for a logged in user.
        # Intended to be used with `cancancan`.
        class CurrentUserAbility
          include CanCan::Ability

          attr_reader :user, :context

          def initialize(user, context)
            return unless user

            @user = user
            @context = context

            can :manage, Decidim::Authorization do |authorization|
              authorization.user == user
            end
          end
        end
      end
    end
  end
end
