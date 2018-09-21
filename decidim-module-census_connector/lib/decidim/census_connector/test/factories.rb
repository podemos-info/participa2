# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryBot.modify do
  factory :user do
    trait :with_person do
      transient do
        person_id { 1 }
        scope { create(:scope) }
        state { "enabled" }
        verification { "not_verified" }
        membership_level { "follower" }
      end

      after(:create) do |user, evaluator|
        create(:authorization, user: user,
                               name: "census",
                               metadata: {
                                 "person_id" => 1,
                                 "scope_code" => evaluator.scope.code,
                                 "state" => evaluator.state,
                                 "verification" => evaluator.verification,
                                 "membership_level" => evaluator.membership_level
                               })
      end
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
