# frozen_string_literal: true

source "https://rubygems.org"

ruby "2.4.2"

gem "dotenv-rails", require: "dotenv/rails-now"

gem "decidim", path: "../decidim"
gem "decidim-census_connector", path: "../decidim-module-census_connector"
gem "decidim-collaborations", path: "../decidim-module-crowdfundings"
gem "decidim-votings", path: "../decidim-module-votings"
gem "decidim-module-blogs", path: "../decidim-module-blogs"

gem "faker", "~> 1.8.4"
gem "puma", "~> 3.0"

group :development, :test do
  gem "byebug", platform: :mri
  gem "decidim-dev", path: "../decidim"
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "capistrano", "~> 3.6", require: false
  gem "capistrano-rails", "~> 1.3", require: false
  gem "capistrano-rvm", require: false
  gem "capistrano3-puma", require: false
  gem "letter_opener_web", "~> 1.3.0"
  gem "listen", "~> 3.1.0"
  gem "i18n-debug"
  gem "pry"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
