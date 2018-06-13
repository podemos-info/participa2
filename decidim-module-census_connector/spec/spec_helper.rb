# frozen_string_literal: true

require "decidim/dev"

ENV["ENGINE_NAME"] = File.dirname(__dir__).split("/").last

Decidim::Dev.dummy_app_path = File.expand_path("spec/decidim_dummy_app")

require "decidim/dev/test/base_spec_helper"

require "support/vcr"

RSpec.configure do |config|
  config.include Capybara::ScopesPicker, type: :system
end
