# frozen_string_literal: true

Decidim::Verifications.register_workflow(:census) do |workflow|
  workflow.engine = Decidim::CensusConnector::Verifications::Census::Engine
  workflow.admin_engine = Decidim::CensusConnector::Verifications::Census::AdminEngine
  workflow.action_authorizer = "Decidim::CensusConnector::Verifications::Census::ActionAuthorizer"

  workflow.options do |options|
    options.attribute :allowed_document_types, type: :string, default: nil, required: false
    options.attribute :allowed_verification_levels, type: :string, default: nil, required: false
    options.attribute :prioritize_verification, type: :boolean, default: true
    options.attribute :census_closure, type: :string, default: nil, required: false
    options.attribute :enforce_scope, type: :boolean, default: true
    options.attribute :minimum_age, type: :integer, default: 14
  end
end
