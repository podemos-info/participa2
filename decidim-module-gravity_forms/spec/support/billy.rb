# frozen_string_literal: true

require "billy/capybara/rspec"

Billy.configure do |config|
  config.whitelist = [/lvh\.me/, /mozilla/, /digicert/, /ciscobinary/, /firefox/]
  config.cache = true
  config.persist_cache = true
  config.cache_path = "spec/fixtures/billy"
end

Capybara.register_driver :selenium_firefox_headless_billy do |app|
  options = Selenium::WebDriver::Firefox::Options.new
  options.add_argument("--headless")

  capabilities = Selenium::WebDriver::Remote::Capabilities.firefox(
    acceptInsecureCerts: true,
    proxy: {
      http: "#{Billy.proxy.host}:#{Billy.proxy.port}",
      ssl: "#{Billy.proxy.host}:#{Billy.proxy.port}"
    }
  )

  Capybara::Selenium::Driver.new(
    app,
    options: options,
    desired_capabilities: capabilities
  )
end

RSpec.configure do |config|
  config.before(:suite) do
    WebMock.allow_net_connect!
  end
end
