# frozen_string_literal: true

def create_person_scopes(organization, person)
  create_scopes(organization, person.scope_code)
  create_scopes(organization, person.address_scope_code)
  create_scopes(organization, person.document_scope_code)
end

def create_scopes(organization, code)
  code_sum = ""
  scope = nil
  code.split("-").each do |code_part|
    code_sum += code_part
    scope = organization.scopes.find_by(code: code_sum) || FactoryBot.create(:scope, code: code_sum, organization: organization, parent: scope)
    code_sum += "-"
  end
end
