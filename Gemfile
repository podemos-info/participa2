# frozen_string_literal: true

source "https://rubygems.org"

ruby "2.4.1"

gem "decidim", path: "../decidim"
gem "faker", "~> 1.8.4"
gem "puma", "~> 3.0"
gem "uglifier", ">= 1.3.0"

group :development, :test do
  gem "byebug", platform: :mri
  gem "decidim-dev", path: "../decidim"
end

group :development do
  gem "better_errors"
  gem "binding_of_caller"
  gem "letter_opener_web", "~> 1.3.0"
  gem "listen", "~> 3.1.0"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]
