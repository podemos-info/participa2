# frozen_string_literal: true

module Decidim
  module Collaborations
    module Abilities
      # CanCanCan abilities related to current user.
      class CurrentUserAbility
        include CanCan::Ability

        attr_reader :user, :context

        def initialize(user, context)
          return unless user

          @user = user
          @context = context

          can :support, Collaboration do |collaboration|
            collaboration.accepts_supports? &&
              current_settings.collaborations_allowed? &&
              under_collaboration_limit?
          end

          can :support_recurrently, Collaboration do |collaboration|
            collaboration.recurrent_support_allowed? &&
              collaboration.user_collaborations.recurrent.supported_by(user).none?
          end

          can :update, UserCollaboration do |user_collaboration|
            user_collaboration.user.id == user.id && user_collaboration.accepted?
          end

          can :resume, UserCollaboration do |user_collaboration|
            user_collaboration.user.id == user.id && user_collaboration.paused?
          end
        end

        private

        def current_settings
          @context.fetch(:current_settings, nil)
        end

        def under_collaboration_limit?
          user_totals = Census::API::Totals.user_totals(user.id)

          user_totals && user_totals < Decidim::Collaborations.maximum_annual_collaboration
        end
      end
    end
  end
end
