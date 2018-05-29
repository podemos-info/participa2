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
end
