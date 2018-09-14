# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

return if Rails.env.production?

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

desc "Cleanup temporary spec files"
task :clean do
  [:census_connector, :crowdfundings, :gravity_forms, :votings].each do |component|
    rm_r "decidim-module-#{component}/spec/decidim_dummy_app"
  end
end

def system!(*args)
  system(*args) || abort("\n== Command #{args} failed ==")
end

namespace :spec do
  [:census_connector, :crowdfundings, :gravity_forms, :votings].each do |component|
    desc "Run #{component} specs"
    task component do
      folder = "decidim-module-#{component}"

      Dir.chdir(folder) do
        Bundler.with_original_env do
          system("bundle check") || system!("bundle install")

          system!("bundle exec rake test_app") unless Dir.exist?("spec/decidim_dummy_app")

          system!("bundle exec rspec")
        end
      end
    end
  end

  task components: [:census_connector, :crowdfundings, :gravity_forms, :votings]
end

desc "Runs all specs, using existing test apps"
task all_specs: [:spec, :"spec:components"]

desc "Runs all specs, fully resetting all test apps"
task full_specs: [:clean, :all_specs]

task default: :all_specs
