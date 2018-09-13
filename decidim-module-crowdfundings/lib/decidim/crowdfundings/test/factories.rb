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
    manifest_name { :crowdfundings }

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
    default_amount { Decidim::Crowdfundings.selectable_amounts.first }
    minimum_custom_amount { 5 }
    target_amount { 1_000 }
    amounts { Decidim::Crowdfundings.selectable_amounts }
    component { create(:crowdfundings_component, :participatory_process) }

    trait :assembly do
      component { create(:crowdfundings_component, :assembly) }
    end

    trait :allow_recurrent do
      target_amount { nil }
    end
  end

  factory :contribution,
          class: Decidim::Crowdfundings::Contribution do
    campaign { create(:campaign) }
    user { create(:user, :with_person, organization: campaign.component.organization) }
    amount { 50 }
    last_order_request_date { Time.zone.today.beginning_of_month }
    payment_method_id { 1 }

    trait :punctual do
      frequency { "punctual" }
    end

    trait :monthly do
      frequency { "monthly" }
    end

    trait :quarterly do
      frequency { "quarterly" }
    end

    trait :annual do
      frequency { "annual" }
    end

    trait :pending do
      state { "pending" }
    end

    trait :accepted do
      state { "accepted" }
    end

    trait :rejected do
      state { "rejected" }
    end

    trait :paused do
      state { "paused" }
    end
  end

  sequence(:payment_method_id)

  factory :payment_method, class: OpenStruct do
    skip_create

    id { generate(:payment_method_id) }
    name { Faker::Lorem.sentence(1, true, 4) }
    type { %w(PaymentMethods::DirectDebit PaymentMethods::CreditCard).sample }
    status { "active" }
    verified? { false }

    trait :inactive do
      status { "inactive" }
    end

    trait :incomplete do
      status { "incomplete" }
    end

    trait :verified do
      verified? { true }
    end

    trait :direct_debit do
      type { "direct_debit" }
    end

    trait :credit_card do
      type { "credit_card_external" }
    end
  end

  factory :payments_proxy, class: "Decidim::Crowdfundings::PaymentsProxy" do
    skip_create

    transient do
      organization { create(:organization) }
      person_proxy { create(:person_proxy, organization: organization) }
    end

    initialize_with { new(person_proxy) }

    trait :without_person do
      person_proxy { nil }
    end
  end
end
