# frozen_string_literal: true

Decidim.register_component(:crowdfundings) do |component|
  component.engine = Decidim::Crowdfundings::Engine
  component.admin_engine = Decidim::Crowdfundings::AdminEngine
  component.icon = "decidim/crowdfundings/icon.svg"
  component.stylesheet = "decidim/crowdfundings/crowdfundings"
  component.permissions_class_name = "Decidim::Crowdfundings::Permissions"

  component.on(:before_destroy) do |instance|
    raise StandardError, "Can't remove this component" if Decidim::Crowdfundings.where(component: instance).any?
  end

  component.register_resource(:campaign) do |resource|
    resource.model_class_name = "Decidim::Crowdfundings::Campaign"
    resource.template = "decidim/crowdfundings/campaigns/linked_campaigns"
    resource.card = "decidim/crowdfundings/campaign"
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

    raise "The handler for this action must be census" unless permissions && permissions["authorization_handlers"]["census"]

    options = permissions["authorization_handlers"]["census"]["options"]

    minimum_age = options["minimum_age"]
    raise "You need to define a minimum_age key" unless minimum_age
    raise "The minimum age must be at least 18" if minimum_age.to_i < 18

    allowed_document_types = options["allowed_document_types"]
    raise "You need to define an allowed_document_types key" unless allowed_document_types
    raise "Allowed documents can't include passport" if allowed_document_types.include?("passport")
  end

  component.settings(:global) do |settings|
    settings.attribute :resources_permissions_enabled, type: :boolean, default: true
  end

  component.settings(:step) do |settings|
    settings.attribute :contribution_allowed, type: :boolean, default: true
  end

  component.register_stat :some_stat do |_components, _start_at, _end_at|
    # Register some stat number to the application
  end

  component.seeds do |participatory_space|
    component_name = Decidim::Components::Namer.new(
      participatory_space.organization.available_locales,
      :crowdfundings
    )

    component = Decidim::Component.create!(
      name: component_name.i18n_name,
      manifest_name: :crowdfundings,
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

    campaign = Decidim::Crowdfundings::Campaign.create!(
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
      amounts: Decidim::Crowdfundings.selectable_amounts
    )

    3.times do
      author = Decidim::User.where(organization: component.organization).all.sample

      Decidim::Crowdfundings::Contribution.create!(
        user: author,
        campaign: campaign,
        amount: 50,
        state: "accepted",
        last_order_request_date: Time.zone.today.beginning_of_month
      )
    end
  end
end
