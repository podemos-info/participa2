# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

gem "decidim", "~> 0.11", github: "decidim/decidim", branch: "0.11-stable"
gem "decidim-census_connector", path: "."

gem "puma", "~> 3.0"
gem "uglifier", "~> 4.1"

group :development, :test do
  gem "byebug", "~> 10.0", platform: :mri

  gem "decidim-dev", "~> 0.11", github: "decidim/decidim", branch: "0.11-stable"
  gem "xxhash"
end

group :development do
  gem "faker", "~> 1.8"
  gem "faker-spanish_document", "~> 0.1"
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end

group :test do
  gem "vcr", "~> 4.0"
end
