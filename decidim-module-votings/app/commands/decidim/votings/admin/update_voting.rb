# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This command is executed when the user changes a Voting from
      # the admin panel.
      class UpdateVoting < VotingCommand
        # Initializes an UpdateProject Command.
        #
        # form - The form from which to get the data.
        # voting - The current instance of the voting to be updated.
        def initialize(form, voting)
          super(form)
          @voting = voting
        end

        # Updates the voting if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            update_voting
            update_electoral_districts
          end

          broadcast(:ok)
        end

        private

        attr_reader :voting

        def update_voting
          attrs = {
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
            voting_identifier: form.voting_identifier
          }
          append_shared_key(attrs)
          voting.update!(attrs)
        end

        def append_shared_key(attrs)
          attrs[:shared_key] = form.shared_key if form.shared_key.present? && form.change_shared_key && voting.can_change_shared_key?
        end

        def update_electoral_districts
          form.electoral_districts.each do |electoral_district_form|
            electoral_districts = voting.electoral_districts

            if electoral_district_form.for_creation?
              electoral_districts.create!(
                scope: electoral_district_form.scope,
                voting_identifier: electoral_district_form.voting_identifier
              )
            elsif electoral_district_form.for_update?
              electoral_districts.find(electoral_district_form.id).update!(
                scope: electoral_district_form.scope,
                voting_identifier: electoral_district_form.voting_identifier
              )
            else
              electoral_districts.delete(electoral_district_form.id)
            end
          end
        end
      end
    end
  end
end
