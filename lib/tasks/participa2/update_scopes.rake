# frozen_string_literal: true

require "participa2/seeds/scopes"

namespace :participa2 do
  desc "Update scopes with data located on seeds/scopes folder"
  task :update_scopes, [ :organization_id ] => :environment do |t, args|
    organization = Decidim::Organization.find(args[:organization_id])
    base_path = File.expand_path("../../../db/seeds", __dir__)
    Participa2::Seeds::Scopes.seed organization, base_path: base_path
  end
end
