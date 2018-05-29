# frozen_string_literal: true

require "decidim/dev/common_rake"

desc "Generates a dummy app for testing"
task test_app: "decidim:generate_external_test_app"

desc "Generates a development app."
task development_app: "decidim:generate_external_development_app" do
  Dir.chdir("development_app") do
    sh("bin/rails generate decidim:collaborations:install")
  end
end
