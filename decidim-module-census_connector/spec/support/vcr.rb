# frozen_string_literal: true

VCR.configure do |config|
  config.ignore_request do |request|
    URI(request.uri).port != URI(ENV["CENSUS_URL"]).port
  end

  config.cassette_library_dir = File.expand_path("../fixtures/vcr", __dir__)

  config.hook_into :webmock
end
