# frozen_string_literal: true

module RSpecMiscHelper
  def expect_after_subject(object)
    subject

    expect(object) # rubocop:disable RSpec/VoidExpect
  end
end

RSpec.configure do |config|
  config.include RSpecMiscHelper
end
