# frozen_string_literal: true

source "https://rubygems.org"

ruby "2.5.1"

gem "dotenv-rails", require: "dotenv/rails-now"

gem "decidim", git: "https://github.com/decidim/decidim", branch: "0.11-stable"
gem "decidim-census_connector", path: "decidim-module-census_connector"
gem "decidim-collaborations", path: "decidim-module-crowdfundings"
gem "decidim-gravity_forms", path: "decidim-module-gravity_forms"
gem "decidim-votings", path: "decidim-module-votings"

gem "faraday"

gem "faker", "~> 1.8.4"
gem "puma", "~> 3.0"
gem "uglifier", ">= 1.3.0"

group :development, :test do
  gem "byebug", platform: :mri

  gem "decidim-dev", "~> 0.11"
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "capistrano", "~> 3.11.0", require: false
  gem "capistrano-rails", "~> 1.3", require: false
  gem "capistrano-rvm", require: false
  gem "capistrano3-puma", require: false
  gem "i18n-debug"
  gem "letter_opener_web", "~> 1.3.0"
  gem "listen", "~> 3.1.0"
  gem "mdl"
  gem "pry"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console"
end

group :test do
  gem "faker-spanish_document", "~> 0.1"
  gem "puffing-billy", "~> 1.1"
  gem "vcr", "~> 4.0"
  gem "xxhash"
end
