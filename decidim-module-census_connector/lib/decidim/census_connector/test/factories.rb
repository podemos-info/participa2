# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryBot.modify do
  factory :user do
    transient do
      person_id { false }
      scope { nil }
      state { nil }
      verification { nil }
      membership_level { nil }
    end

    trait :with_person do
      transient do
        person_id { 1 }
        state { "enabled" }
        verification { "not_verified" }
        membership_level { "follower" }
        scope { nil }
      end
    end

    trait :with_member_person do
      transient do
        person_id { 2 }
        state { "enabled" }
        verification { "verified" }
        membership_level { "member" }
        scope { nil }
      end
    end

    trait :with_young_person do
      transient do
        person_id { 3 }
        state { "enabled" }
        verification { "not_verified" }
        membership_level { "follower" }
        scope { nil }
      end
    end

    trait :with_cancelled_person do
      transient do
        person_id { 4 }
        state { "cancelled" }
        verification { "not_verified" }
        membership_level { "follower" }
        scope { nil }
      end
    end

    after(:create) do |user, evaluator|
      next unless evaluator.person_id

      metadata = { "person_id" => evaluator.person_id }
      metadata["scope_code"] = evaluator.scope.code if evaluator.scope
      metadata["state"] = evaluator.state if evaluator.state
      metadata["verification"] = evaluator.verification if evaluator.verification
      metadata["membership_level"] = evaluator.membership_level if evaluator.membership_level

      create(:authorization, user: user,
                             name: "census",
                             metadata: metadata)
    end
  end

  factory :scope do
    trait :local do
      code { Decidim::CensusConnector.census_local_code }
      initialize_with { Decidim::Scope.find_or_create_by(code: Decidim::CensusConnector.census_local_code) }
    end
  end
end

FactoryBot.define do
  factory :person_proxy, class: "Decidim::CensusConnector::PersonProxy" do
    skip_create

    transient do
      organization { create(:organization) }
    end

    user { create(:user, :confirmed, :with_person, organization: organization) }

    initialize_with { Decidim::CensusConnector::PersonProxy.for(user) }
  end
end
