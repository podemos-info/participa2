# frozen_string_literal: true

SimpleCov.start "rails" do
  root ENV["ENGINE_ROOT"] ? File.expand_path("..", ENV["ENGINE_ROOT"]) : __dir__

  add_filter "/spec/decidim_dummy_app/"
  add_filter "/.bundle/"

  add_group "Census connector", "decidim-module-census_connector"
  add_group "Crowdfundings", "decidim-module-crowdfundings"
  add_group "Gravity forms", "decidim-module-gravity_forms"
  add_group "Votings", "decidim-module-votings"
end

SimpleCov.command_name ENV["COMMAND_NAME"] || File.basename(Dir.pwd)

SimpleCov.merge_timeout 1800
