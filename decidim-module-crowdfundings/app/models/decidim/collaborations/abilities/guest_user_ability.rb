# frozen_string_literal: true

module Decidim
  module Collaborations
    module Abilities
      # Defines the abilities for guest users..
      # Intended to be used with `cancancan`.
      class GuestUserAbility
        include CanCan::Ability

        attr_reader :context

        def initialize(user, context)
          return if user

          @context = context

          can :support, Collaboration do |collaboration|
            collaboration.accepts_supports? &&
              current_settings&.collaborations_allowed?
          end
        end

        private

        def current_settings
          @context.fetch(:current_settings, nil)
        end
      end
    end
  end
end
