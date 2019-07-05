# frozen_string_literal: true

require "billy/capybara/rspec"

Billy.configure do |config|
  config.whitelist = [/lvh\.me/]
  config.cache = true
  config.persist_cache = true
  config.cache_path = "spec/fixtures/billy"
  config.proxied_request_connect_timeout = 20
  config.proxied_request_inactivity_timeout = 20
end

Capybara.register_driver :chrome_headless_billy do |app|
  WebMock.allow_net_connect!
  options = Selenium::WebDriver::Chrome::Options.new

  [
    "--proxy-server=http://#{Billy.proxy.host}:#{Billy.proxy.port}",
    "--headless",
    "--ignore-certificate-errors",
    "--disable-gpu",
    "--no-sandbox"
  ].each { |arg| options.add_argument(arg) }

  ::Capybara::Selenium::Driver.new(app,
                                   browser: :chrome,
                                   options: options)
end

Capybara.default_max_wait_time = 20

RSpec.configure do |config|
  config.before(:each, type: :system, billy: true) do
    driven_by :chrome_headless_billy
  end
end
