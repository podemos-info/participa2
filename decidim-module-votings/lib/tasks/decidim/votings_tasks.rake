# frozen_string_literal: true

namespace :decidim_votings do
  desc "Install decidim-votings migrations"
  task upgrade: [:choose_target_plugin, :"railties:install:migrations"]

  desc "Setup environment so that only decidim-votings migrations are installed"
  task :choose_target_plugin do
    ENV["FROM"] = "decidim_votings"
  end
end
