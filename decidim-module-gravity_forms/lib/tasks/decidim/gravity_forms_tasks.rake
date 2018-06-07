# frozen_string_literal: true

namespace :decidim_gravity_forms do
  desc "Install decidim-gravity_forms migrations"
  task upgrade: [:choose_target_plugin, :"railties:install:migrations"]

  desc "Setup environment so that only decidim-gravity_forms migrations are installed"
  task :choose_target_plugin do
    ENV["FROM"] = "decidim_gravity_forms"
  end
end
