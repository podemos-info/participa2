# frozen_string_literal: true

module Decidim
  module Votings
    module Abilities
      class CurrentUserAbility
        include CanCan::Ability

        attr_reader :user, :context

        def initialize(user, context)
          return unless user

          @user = user
          @context = context

          can :vote, Voting do |voting|
            result = !voting.finished?
            if result && component_settings.remote_authorization_url.present?
              result = Decidim::Votings::RemoteAuthorizer.new(component_settings.remote_authorization_url).authorized?(user, voting)
            end
            result
          end
        end

        private

        def component_settings
          @context.fetch(:component_settings, nil)
        end
      end
    end
  end
end
