# frozen_string_literal: true

SimpleCov.start do
  root ENV["ENGINE_ROOT"] ? File.expand_path("..", ENV["ENGINE_ROOT"]) : __dir__

  add_filter "/spec/decidim_dummy_app/"
  add_filter "/.bundle/"
end

SimpleCov.command_name ENV["COMMAND_NAME"] || File.basename(Dir.pwd)

SimpleCov.merge_timeout 1800
