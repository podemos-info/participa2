# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryBot.define do
  factory :voting_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :votings).i18n_name }
    manifest_name :votings
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }

    trait :participatory_process do
      participatory_space do
        create(:participatory_process, :with_steps, organization: organization)
      end
    end
  end

  factory :voting, class: "Decidim::Votings::Voting" do
    title { Decidim::Faker::Localized.sentence(3) }
    description { Decidim::Faker::Localized.wrapped("<p>", "</p>") { Decidim::Faker::Localized.sentence(4) } }
    simulation_code 0
    component { create(:voting_component) }
    start_date { DateTime.current - 2.days }
    end_date { DateTime.current + 2.days }

    trait :n_votes do
      voting_system { "nVotes" }
      voting_domain_name { "example.org" }
      voting_identifier { 666 }
      shared_key { "SHARED_KEY" }
    end

    trait :not_started do
      start_date { DateTime.current + 1.month }
    end

    trait :upcoming do
      start_date { DateTime.current + 6.hours }
    end

    trait :finished do
      end_date { DateTime.current - 6.hours }
    end
  end

  factory :electoral_district, class: "Decidim::Votings::ElectoralDistrict" do
    scope
    voting

    voting_identifier 999
  end

  factory :vote, class: "Decidim::Votings::Vote" do
    voting { create(:voting) }
    user { create(:user) }
    status { "pending" }
    trait :confirmed do
      status { :confirmed }
    end
  end

  factory :simulated_vote, class: "Decidim::Votings::SimulatedVote" do
    voting { create(:voting) }
    user { create(:user) }
    simulation_code { 666 }
    status { "pending" }
    trait :confirmed do
      status { :confirmed }
    end
  end
end
