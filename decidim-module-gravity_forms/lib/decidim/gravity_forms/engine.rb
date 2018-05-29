# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module GravityForms
    # This is the engine that runs on the public interface of gravity_forms.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::GravityForms

      routes do
        resources :gravity_forms, only: [:index, :show]

        root to: "gravity_forms#index"
      end

      initializer "decidim_gravity_forms.assets" do |app|
        app.config.assets.precompile += %w(decidim_gravity_forms_manifest.js decidim_gravity_forms_manifest.css)
      end
    end
  end
end
