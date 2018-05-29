# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/collaborations/version"

Gem::Specification.new do |s|
  s.version = Decidim::Collaborations.version
  s.authors = ["Juan Salvador Perez Garcia"]
  s.email = ["jsperezg@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/podemos-info/decidim-module-crowdfundings"
  s.required_ruby_version = ">= 2.3.1"

  s.name = "decidim-collaborations"
  s.summary = "A decidim collaboration module"
  s.description = "Adds the possibility of having crowdfunding campaigns within participatory spaces"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  compatible_constraint = "#{Gem::Version.new(s.version).approximate_recommendation}.a"

  s.add_dependency "decidim-admin", compatible_constraint
  s.add_dependency "decidim-census_connector", compatible_constraint
  s.add_dependency "decidim-core", compatible_constraint
  s.add_dependency "httparty"
  s.add_dependency "iban_bic"
end
