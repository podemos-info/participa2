# frozen_string_literal: true

require "decidim/components/namer"

Decidim.register_component(:collaborations) do |component|
  component.engine = Decidim::Collaborations::Engine
  component.admin_engine = Decidim::Collaborations::AdminEngine
  component.icon = "decidim/collaborations/icon.svg"
  component.stylesheet = "decidim/collaborations/collaborations"
  component.permissions_class_name = "Decidim::Collaborations::Permissions"

  component.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this component" if Decidim::Collaboration.where(component: instance).any?
  end

  component.register_resource(:collaboration) do |resource|
    resource.model_class_name = "Decidim::Collaborations::Collaboration"
    resource.template = "decidim/collaborations/collaborations/linked_collaborations"
    resource.card = "decidim/collaborations/collaboration"
    resource.actions = %w(support)
  end

  # These actions permissions can be configured in the admin panel
  component.actions = %w(support)

  # Default authorization workflow for all component instances
  component.on(:create) do |instance|
    instance.update!(
      permissions: {
        "support" => {
          "authorization_handler_name" => "census",
          "options" => {
            "minimum_age" => 18,
            "allowed_document_types" => "dni,nie"
          }
        }
      }
    )
  end

  # Ensure any authorization follow general rules
  component.on(:permission_update) do |instances|
    instance = instances[:resource] || instances[:component]
    permissions = instance.permissions["support"]

    handler_name = permissions["authorization_handler_name"]
    raise "The handler for this action must be census" if handler_name != "census"

    options = permissions["options"]

    minimum_age = options["minimum_age"]
    raise "You need to define a minimum_age key" unless minimum_age
    raise "The minimum age must be at least 18" if minimum_age.to_i < 18

    allowed_document_types = options["allowed_document_types"]
    raise "You need to define an allowed_document_types key" unless allowed_document_types
    raise "Allowed documents need to include DNI and NIE" unless allowed_document_types.include?("dni") && allowed_document_types.include?("nie")
  end

  component.settings(:global) do |settings|
    settings.attribute :resources_permissions_enabled, type: :boolean, default: true
  end

  component.settings(:step) do |settings|
    settings.attribute :collaborations_allowed, type: :boolean, default: true
  end

  component.register_stat :some_stat do |_components, _start_at, _end_at|
    # Register some stat number to the application
  end

  component.seeds do |participatory_space|
    component_name = Decidim::Components::Namer.new(
      participatory_space.organization.available_locales,
      :collaborations
    )

    component = Decidim::Component.create!(
      name: component_name.i18n_name,
      manifest_name: :collaborations,
      published_at: Time.current,
      participatory_space: participatory_space
    )

    component.update!(
      permissions: {
        "support" => {
          "authorization_handler_name" => "census",
          "options" => {
            "minimum_age" => 18,
            "allowed_document_types" => "dni,nie"
          }
        }
      }
    )

    collaboration = Decidim::Collaborations::Collaboration.create!(
      component: component,
      title: Decidim::Faker::Localized.sentence(2),
      description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(3)
      end,
      terms_and_conditions: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(5)
      end,
      minimum_custom_amount: 1_000,
      target_amount: 100_000,
      default_amount: 100,
      amounts: Decidim::Collaborations.selectable_amounts
    )

    3.times do
      author = Decidim::User.where(organization: component.organization).all.sample

      Decidim::Collaborations::UserCollaboration.create!(
        user: author,
        collaboration: collaboration,
        amount: 50,
        state: "accepted",
        last_order_request_date: Time.zone.today.beginning_of_month
      )
    end
  end
end
