# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Model for crowdfundings campaigns defined inside a
    # participatory space.
    class Campaign < Decidim::Crowdfundings::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasComponent
      include Decidim::HasReference
      include Decidim::Followable

      component_manifest_name "crowdfundings"

      has_many :contributions,
               class_name: "Decidim::Crowdfundings::Contribution",
               foreign_key: "decidim_crowdfundings_campaign_id",
               dependent: :restrict_with_error,
               inverse_of: :campaign

      scope :for_component, ->(component) { where(component: component) }
      scope :active, -> { where("active_until IS NULL or active_until >= ?", Time.zone.now) }

      # PUBLIC: Returns the amount collected by the campaign
      def total_collected
        @total_collected ||= Census::API::Totals.campaign_totals(id)
      end

      # PUBLIC Returns true if the crowdfunding campaign accepts supports.
      def accepts_supports?
        component.participatory_space.published? &&
          (active_until.nil? || active_until >= Time.zone.now)
      end

      # PUBLIC returns the percentage of funds supported with regards to
      # the total collected
      def percentage
        census_total_collected = total_collected
        return if census_total_collected.nil?

        result = (census_total_collected * 100.0) / target_amount
        result = 100.0 if result > 100
        result
      end

      # PUBLIC returns the percentage of funds supported by a user
      # with regards to the total collected.
      def user_percentage(user)
        census_user_total_collected = user_total_collected(user)
        return if census_user_total_collected.nil?

        result = (census_user_total_collected * 100.0) / target_amount
        result = 100.0 if result > 100
        result
      end

      # PUBLIC returns whether recurrent supports are allowed or not.
      def recurrent_support_allowed?
        component&.participatory_space_type == "Decidim::Assembly"
      end

      def allow_resource_permissions?
        component.settings.resources_permissions_enabled
      end

      def inactive?
        active_until && active_until < Time.zone.today
      end

      def active?
        !inactive?
      end

      # PUBLIC returns the amount supported by a user
      def user_total_collected(user)
        Census::API::Totals.user_campaign_totals(user.id, id)
      end

      # PUBLIC returns if a user is under the annual limit. Can be nil if service is not available.
      def under_annual_limit?(user, add_amount: 0)
        user_totals = Census::API::Totals.user_totals(user.id)
        return nil if user_totals.nil?

        user_totals + add_amount < Decidim::Crowdfundings.maximum_annual_contribution_amount
      end
    end
  end
end
