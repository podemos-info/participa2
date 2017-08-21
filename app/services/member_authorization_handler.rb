# frozen_string_literal: true

class MemberAuthorizationHandler < CensusAuthorizationHandler
  def level
    "member"
  end

  def self.order
    2
  end
end