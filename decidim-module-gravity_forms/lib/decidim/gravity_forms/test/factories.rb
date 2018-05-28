# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  sequence(:gravity_form_slug) do |n|
    "#{Faker::Internet.slug(nil, "-")}-#{n}"
  end

  factory :gravity_forms_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :gravity_forms).i18n_name }
    manifest_name :gravity_forms
    participatory_space { create(:participatory_process, :with_steps) }
  end

  factory :gravity_form, class: "Decidim::GravityForms::GravityForm" do
    title { Decidim::Faker::Localized.sentence }
    description { Decidim::Faker::Localized.sentence(3) }
    slug { generate(:gravity_form_slug) }
    form_number 1
    require_login false
    component { create(:gravity_forms_component) }
  end
end
