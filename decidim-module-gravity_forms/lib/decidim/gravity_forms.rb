# frozen_string_literal: true

require "decidim/gravity_forms/admin"
require "decidim/gravity_forms/engine"
require "decidim/gravity_forms/admin_engine"
require "decidim/gravity_forms/component"

module Decidim
  # This namespace holds the logic of the `GravityForms` component. This component
  # allows users to create gravity_forms in a participatory space.
  module GravityForms
    include ActiveSupport::Configurable

    # A proc or a class implementing  a `call` method to customize the embed url
    # for a given user
    config_accessor :customize_embed_url do
      ->(_user, url) { url }
    end
  end
end
