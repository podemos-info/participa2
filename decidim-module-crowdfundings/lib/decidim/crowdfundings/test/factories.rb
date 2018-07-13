# frozen_string_literal: true

require "decidim/faker/localized"
require "decidim/dev"

FactoryBot.define do
  factory :crowdfundings_component, parent: :component do
    name do
      Decidim::Components::Namer.new(
        participatory_space.organization.available_locales,
        :crowdfundings
      ).i18n_name
    end
    manifest_name :crowdfundings

    trait :participatory_process do
      participatory_space do
        create(:participatory_process, :with_steps, organization: organization)
      end
    end

    trait :assembly do
      participatory_space { create(:assembly, :published) }
    end
  end

  factory :campaign, class: Decidim::Crowdfundings::Campaign do
    title { Decidim::Faker::Localized.sentence(3) }
    description do
      Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.sentence(4)
      end
    end
    terms_and_conditions do
      Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(5)
      end
    end
    default_amount 50
    minimum_custom_amount 500
    target_amount 10_000
    amounts { Decidim::Crowdfundings.selectable_amounts }
    component { create(:crowdfundings_component, :participatory_process) }

    trait :assembly do
      component { create(:crowdfundings_component, :assembly) }
    end
  end

  factory :contribution,
          class: Decidim::Crowdfundings::Contribution do
    campaign { create(:campaign) }
    user { create(:user, organization: campaign.component.organization) }
    amount 50
    last_order_request_date { Time.zone.today.beginning_of_month }

    trait :punctual do
      frequency "punctual"
    end

    trait :monthly do
      frequency "monthly"
    end

    trait :quarterly do
      frequency "quarterly"
    end

    trait :annual do
      frequency "annual"
    end

    trait :pending do
      state "pending"
    end

    trait :accepted do
      state "accepted"
    end

    trait :rejected do
      state "rejected"
    end

    trait :paused do
      state "paused"
    end
  end
end
