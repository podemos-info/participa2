# frozen_string_literal: true

require "billy/capybara/rspec"

Billy.configure do |config|
  config.whitelist = [/lvh\.me/, /mozilla/, /digicert/, /ciscobinary/, /firefox/]
  config.cache = true
  config.persist_cache = true
  config.cache_path = "spec/fixtures/billy"
end

Capybara.register_driver :chrome_headless_billy do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  [
    "--proxy-server=http://#{Billy.proxy.host}:#{Billy.proxy.port}",
    "--headless",
    "--ignore-certificate-errors",
    "--disable-gpu",
    "--no-sandbox",
    "--window-size=800,600"
  ].each { |arg| options.add_argument(arg) }

  ::Capybara::Selenium::Driver.new(app,
                                   browser: :chrome,
                                   options: options)
end

RSpec.configure do |config|
  config.before(:suite) do
    WebMock.allow_net_connect!
  end
end
