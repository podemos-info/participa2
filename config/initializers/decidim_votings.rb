# frozen_string_literal: true

Decidim::Votings.configure do |config|
  config.scope_resolver = lambda do |user, voting|
    authorizer_options = action_authorizer_options(voting)
    return nil unless authorizer_options

    version_at = authorizer_options.census_closure if authorizer_options.authorizing_by_census_closure?
    enforce_scope = authorizer_options.authorizing_by_scope?

    parent_scope = voting.scope || voting.component.participatory_space.try(:scope)
    person = Decidim::CensusConnector::PersonProxy.for(user, version_at: version_at).person

    return false if enforce_scope && parent_scope && !parent_scope.ancestor_of?(person.scope)

    person.scope
  end
end

def action_authorizer_options(voting)
  vote_permissions = voting&.permissions&.fetch("vote", nil) || voting.component.permissions&.fetch("vote", nil)

  if vote_permissions&.fetch("authorization_handler_name") == "census"
    Decidim::CensusConnector::Verifications::Census::ActionAuthorizerOptions.new(
      vote_permissions["options"] || {}
    )
  end
end
