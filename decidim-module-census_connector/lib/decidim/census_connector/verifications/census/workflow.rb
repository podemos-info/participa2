# frozen_string_literal: true

Decidim::Verifications.register_workflow(:census) do |workflow|
  workflow.engine = Decidim::CensusConnector::Verifications::Census::Engine
  workflow.admin_engine = Decidim::CensusConnector::Verifications::Census::AdminEngine
  workflow.action_authorizer = "Decidim::CensusConnector::Verifications::Census::ActionAuthorizer"

  workflow.options do |options|
    options.attribute :allowed_document_types, type: :string, default: "dni,nie"
    options.attribute :minimum_age, type: :integer, default: 18
  end
end
