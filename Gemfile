# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby "2.4.2"

gem "dotenv-rails", require: "dotenv/rails-now"

gem "decidim", github: "decidim/decidim", branch: "master"
gem "decidim-census_connector", github: "podemos-info/decidim-module-census_connector", branch: "master"
gem "decidim-collaborations", github: "podemos-info/decidim-module-crowdfundings", branch: "master"
gem "decidim-votings", github: "podemos-info/decidim-module-votings", branch: "master"
gem "decidim-module-blogs", github: "decidim/decidim-module-blogs", branch: "master"

gem "faker", "~> 1.8.4"
gem "puma", "~> 3.0"
gem "uglifier", ">= 1.3.0"

group :development, :test do
  gem "byebug", platform: :mri

  gem "decidim-dev", github: "decidim/decidim", branch: "master"
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
