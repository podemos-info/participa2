# frozen_string_literal: true

Decidim::Verifications.register_workflow(:census) do |workflow|
  workflow.engine = Decidim::CensusConnector::Verifications::Census::Engine
  workflow.admin_engine = Decidim::CensusConnector::Verifications::Census::AdminEngine
  workflow.action_authorizer = "Decidim::CensusConnector::Verifications::Census::ActionAuthorizer"
end
