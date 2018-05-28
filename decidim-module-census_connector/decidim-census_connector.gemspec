# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/census_connector/version"

Gem::Specification.new do |s|
  s.version = Decidim::CensusConnector.version
  s.authors = ["Leonardo Diez"]
  s.email = ["leiodd@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/podemos-info/decidim-module-census_connector"
  s.required_ruby_version = ">= 2.3.1"

  s.name = "decidim-census_connector"
  s.summary = "A Decidim module that allows to connect it to Podemos Census application."
  s.description = s.summary

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "Rakefile", "README.md"]

  compatible_constraint = "#{Gem::Version.new(s.version).approximate_recommendation}.a"

  s.add_dependency "decidim-core", compatible_constraint
  s.add_dependency "decidim-verifications", compatible_constraint
  s.add_dependency "httparty"

  s.add_development_dependency "decidim-dev", compatible_constraint
end
