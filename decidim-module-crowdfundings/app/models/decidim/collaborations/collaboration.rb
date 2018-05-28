# frozen_string_literal: true

module Decidim
  module Collaborations
    # Model for collaboration campaigns defined inside a
    # participatory space.
    class Collaboration < Decidim::Collaborations::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasComponent
      include Decidim::Followable

      component_manifest_name "collaborations"

      has_many :user_collaborations,
               class_name: "Decidim::Collaborations::UserCollaboration",
               foreign_key: "decidim_collaborations_collaboration_id",
               dependent: :restrict_with_error,
               inverse_of: :collaboration

      scope :for_component, ->(component) { where(component: component) }

      # PUBLIC: Returns the amount collected by the campaign
      def total_collected
        @total_collected ||= Census::API::Totals.campaign_totals(id)
      end

      # PUBLIC Returns true if the collaboration campaign accepts supports.
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

      # PUBLIC returns the amount supported by a user
      def user_total_collected(user)
        Census::API::Totals.user_campaign_totals(user.id, id)
      end

      # PUBLIC returns whether recurrent supports are allowed or not.
      def recurrent_support_allowed?
        component&.participatory_space_type == "Decidim::Assembly"
      end
    end
  end
end
