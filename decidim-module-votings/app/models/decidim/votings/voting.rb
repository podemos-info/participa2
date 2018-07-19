# frozen_string_literal: true

module Decidim
  module Votings
    # Model for collaboration campaigns defined inside a
    # participatory space.
    class Voting < Decidim::Votings::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::HasComponent
      include Decidim::Followable
      include Decidim::ScopableComponent

      component_manifest_name "votings"

      mount_uploader :image, Decidim::Votings::VotingUploader

      store_accessor :system_configuration, :voting_domain_name, :voting_identifier, :shared_key

      validates :image, file_size: { less_than_or_equal_to: ->(_attachment) { Decidim.maximum_attachment_size } }

      has_many :votes, foreign_key: "decidim_votings_voting_id", inverse_of: :voting, dependent: :destroy
      has_many :simulated_votes, foreign_key: "decidim_votings_voting_id", inverse_of: :voting, dependent: :destroy

      has_many :electoral_districts, foreign_key: "decidim_votings_voting_id", inverse_of: :voting, dependent: :destroy

      scope :for_component, ->(component) { where(component: component) }
      scope :active, -> { where("? BETWEEN start_date AND end_date", Time.zone.now) }
      scope :order_by_importance, -> { order(:importance) }

      def active?
        started? && !finished?
      end

      def started?
        start_date < Time.zone.now
      end

      def finished?
        end_date < Time.zone.now
      end

      def simulating?
        !started?
      end

      def vote_class
        started? ? Vote : SimulatedVote
      end

      def target_votes
        started? ? votes : simulated_votes.by_simulation_code(simulation_code)
      end

      def simulation_key
        Digest::SHA256.hexdigest("#{Rails.application.secrets.secret_key_base}:#{created_at}:#{id}:#{voting_system}")
      end

      def status
        return :upcoming unless started?
        return :closed if finished?
        :active
      end

      def has_voted?(user)
        target_votes.by_user(user).first&.confirmed?
      end

      def can_change_shared_key?
        simulated_votes.empty? && votes.empty?
      end

      def allow_resource_permissions?
        component.settings.resources_permissions_enabled
      end

      def voting_identifier_for(user_scope)
        raise "Invalid user scope for this voting" if scope && user_scope && !scope.ancestor_of?(user_scope)

        district_voting_identifier = ordered_electoral_districts(user_scope.part_of).map(&:voting_identifier).first if user_scope
        district_voting_identifier || voting_identifier
      end

      private

      def ordered_electoral_districts(scope_ids)
        electoral_districts.where(decidim_scope_id: scope_ids).sort do |district1, district2|
          scope_ids.index(district2.id) <=> scope_ids.index(district1.id)
        end
      end
    end
  end
end
