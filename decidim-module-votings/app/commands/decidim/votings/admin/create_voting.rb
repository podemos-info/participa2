# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This command is executed when the user creates a Voting from
      # the admin panel.
      class CreateVoting < VotingCommand
        # Creates the project if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            @voting = create_voting
            create_electoral_districts
          end

          broadcast(:ok)
        end

        private

        def create_voting
          Voting.create!(
            component: form.current_component,
            title: form.title,
            description: form.description,
            image: form.image,
            start_date: form.start_date,
            end_date: form.end_date,
            scope: form.scope,
            importance: form.importance,
            census_date_limit: form.census_date_limit,
            simulation_code: form.simulation_code,
            voting_system: form.voting_system,
            voting_domain_name: form.voting_domain_name,
            voting_identifier: form.voting_identifier,
            shared_key: form.shared_key
          )
        end

        def create_electoral_districts
          form.electoral_districts.each do |electoral_district_form|
            @voting.electoral_districts.create!(
              scope: electoral_district_form.scope,
              voting_identifier: electoral_district_form.voting_identifier
            )
          end
        end
      end
    end
  end
end
