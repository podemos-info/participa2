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
      scope :active, -> { where("? BETWEEN start_date AND end_date", DateTime.current) }
      scope :order_by_importance, -> { order(:importance) }

      def active?
        (start_date.to_datetime..end_date.to_datetime).cover? DateTime.current
      end

      def in_census_limit?(user)
        user.created_at < census_date_limit
      end

      def in_scope?(_user)
        true
      end

      def started?
        start_date < Time.zone.now
      end

      def finished?
        end_date < Time.zone.now
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

      def voting_identifier_for(scope)
        scope.part_of.each do |scope_id|
          return voting_identifier if decidim_scope_id == scope_id

          electoral_district = electoral_districts.find_by(decidim_scope_id: scope_id)
          return electoral_district.voting_identifier if electoral_district
        end

        nil
      end
    end
  end
end
