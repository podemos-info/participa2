# frozen_string_literal: true

module Decidim
  module GravityForms
    module Abilities
      module Admin
        # Defines the abilities related to gravity_forms for a logged in admin user.
        # Intended to be used with `cancancan`.
        class AdminAbility < Decidim::Abilities::AdminAbility
          def define_abilities
            can :manage, GravityForm
          end
        end
      end
    end
  end
end
