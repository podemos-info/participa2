# frozen_string_literal: true

namespace :decidim_crowdfundings do
  desc "Executes recurrent payment orders"
  task recurrent_contributions: :environment do
    Decidim::Crowdfundings::RenewContributions.run
  end

  desc "Update status of payment orders"
  task update_status: :environment do
    Decidim::Crowdfundings::RefreshContributions.run
  end

  desc "Install decidim-crowdfundings migrations"
  task upgrade: [:choose_target_plugin, :"railties:install:migrations"]

  desc "Setup environment so that only decidim-crowdfundings migrations are installed."
  task :choose_target_plugin do
    ENV["FROM"] = "decidim_crowdfundings"
  end
end
