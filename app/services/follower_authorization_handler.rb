# frozen_string_literal: true

class FollowerAuthorizationHandler < CensusAuthorizationHandler
  def level
    "follower"
  end

  def self.order
    1
  end
end