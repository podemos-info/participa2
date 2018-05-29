# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/gravity_forms/version"

Gem::Specification.new do |s|
  s.version = Decidim::GravityForms.version
  s.authors = ["David Rodríguez"]
  s.email = ["deivid.rodriguez@riseup.net"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-gravity_forms"
  s.required_ruby_version = ">= 2.3.1"

  s.name = "decidim-gravity_forms"
  s.summary = "A decidim gravity_forms module"
  s.description = "A gravity forms component for Decidim."

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]

  compatible_constraint = "#{Gem::Version.new(s.version).approximate_recommendation}.a"

  s.add_dependency "decidim-core", compatible_constraint
end
