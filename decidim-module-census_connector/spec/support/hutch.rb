# frozen_string_literal: true

require "hutch"

Rails.application.config.eager_load_paths += Dir["app/consumers/**/"]
