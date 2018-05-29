# frozen_string_literal: true

require_dependency "decidim/components/namer"

Decidim.register_component(:gravity_forms) do |component|
  component.engine = Decidim::GravityForms::Engine
  component.admin_engine = Decidim::GravityForms::AdminEngine
  component.icon = "decidim/gravity_forms/icon.svg"

  # component.on(:before_destroy) do |instance|
  #   # Code executed before removing the component
  # end

  # These actions permissions can be configured in the admin panel
  # component.actions = %w()

  component.settings(:global) do |settings|
    settings.attribute :domain, type: :string
  end

  # component.settings(:step) do |settings|
  #   # Add your settings per step
  # end

  component.register_resource do |resource|
    resource.model_class_name = "Decidim::GravityForms::GravityForm"
  end

  # component.register_stat :some_stat do |context, start_at, end_at|
  #   # Register some stat number to the application
  # end

  component.seeds do |participatory_space|
    component = Decidim::Component.create!(
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :gravity_forms).i18n_name,
      manifest_name: :gravity_forms,
      published_at: Time.current,
      participatory_space: participatory_space,
      settings: {
        domain: "bored-sloth.w6.gravitydemo.com"
      }
    )

    Decidim::GravityForms::GravityForm.create!(
      component: component,
      title: Decidim::Faker::Localized.sentence,
      description: Decidim::Faker::Localized.sentence(3),
      slug: Faker::Internet.unique.slug(nil, "-"),
      form_number: 1
    )
  end
end
