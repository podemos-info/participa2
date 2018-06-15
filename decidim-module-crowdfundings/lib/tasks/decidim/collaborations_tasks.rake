# frozen_string_literal: true

namespace :decidim_collaborations do
  desc "Executes recurrent payment orders"
  task recurrent_collaborations: :environment do
    Decidim::Collaborations::RenewUserCollaborations.run
  end

  desc "Update status of payment orders"
  task update_status: :environment do
    Decidim::Collaborations::RefreshUserCollaborations.run
  end

  desc "Install decidim-crowdfundings migrations"
  task upgrade: [:choose_target_plugin, :"railties:install:migrations"]

  desc "Setup environment so that only decidim-crowdfundings migrations are installed."
  task :choose_target_plugin do
    ENV["FROM"] = "decidim_collaborations"
  end
end
