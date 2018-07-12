# frozen_string_literal: true

module Decidim
  module Crowdfundings
    module Admin
      # This command is executed when the user changes a campaign from
      # the admin panel.
      class UpdateCampaign < CampaignCommand
        # Initializes an UpdateCampaign Command.
        #
        # form - The form from which to get the data.
        # campaign - The current instance of the campaign to be updated.
        def initialize(form, campaign)
          super(form)
          @campaign = campaign
        end

        # Updates the campaign if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if form.invalid?

          update_campaign
          broadcast(:ok)
        end

        private

        attr_reader :campaign

        def update_campaign
          campaign.update!(
            title: form.title,
            description: form.description,
            terms_and_conditions: form.terms_and_conditions,
            default_amount: form.default_amount,
            minimum_custom_amount: form.minimum_custom_amount,
            target_amount: form.target_amount,
            active_until: form.active_until,
            amounts: amounts
          )
        end
      end
    end
  end
end
