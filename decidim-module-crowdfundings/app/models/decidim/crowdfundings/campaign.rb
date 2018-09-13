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

      # PUBLIC Returns true if the crowdfunding campaign accepts new contributions.
      def accepts_contributions?
        component.participatory_space.published? && active?
      end

      # PUBLIC returns whether recurrent supports are allowed or not.
      def recurrent_support_allowed?
        target_amount.nil? && component&.participatory_space_type == "Decidim::Assembly"
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
    end
  end
end
