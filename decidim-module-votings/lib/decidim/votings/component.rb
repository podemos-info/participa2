# frozen_string_literal: true

Decidim.register_component(:votings) do |component|
  component.engine = Decidim::Votings::Engine
  component.admin_engine = Decidim::Votings::AdminEngine
  component.icon = "decidim/votings/icon.svg"

  component.on(:before_destroy) do |instance|
    # Code executed before removing the component
  end

  component.register_resource do |resource|
    resource.model_class_name = "Decidim::Votings::Voting"
    resource.template = "decidim/votings/votings/linked_votings"
  end

  # These actions permissions can be configured in the admin panel
  component.actions = %w(vote)

  component.settings(:global) do |settings|
    # Add your global settings
    # Available types: :integer, :boolean
    settings.attribute :remote_authorization_url, type: :string, default: nil
  end

  component.settings(:step) do |settings|
    # Add your settings per step
  end

  # # Register an optional resource that can be referenced from other resources.
  # component.register_resource do |resource|
  #   resource.model_class_name = "Decidim::<EngineName>::<ResourceName>"
  #   resource.template = "decidim/<engine_name>/<resource_view_folder>/linked_<resource_name_plural>"
  # end

  component.register_stat :some_stat do |components, start_at, end_at|
    # Register some stat number to the application
  end

  component.seeds do |participatory_space|
    component = Decidim::Component.create!(
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :votings).i18n_name,
      manifest_name: :votings,
      published_at: Time.current,
      participatory_space: participatory_space
    )

    3.times do
      Decidim::Votings::Voting.create!(
        component: component,
        title: Decidim::Faker::Localized.sentence(3),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.sentence(4)
        end,
        simulation_code: 0,
        start_date: 2.days.ago,
        end_date: 2.days.from_now,
        census_date_limit: 2.days.from_now,
        voting_system: "nVotes",
        voting_domain_name: "example.org",
        voting_identifier: 666,
        shared_key: "SHARED_KEY"
      )
    end
  end
end
