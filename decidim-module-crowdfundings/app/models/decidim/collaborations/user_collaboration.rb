# frozen_string_literal: true

module Decidim
  module Collaborations
    class UserCollaboration < Decidim::Collaborations::ApplicationRecord
      belongs_to :collaboration,
                 class_name: "Decidim::Collaborations::Collaboration",
                 foreign_key: "decidim_collaborations_collaboration_id",
                 touch: true,
                 inverse_of: :user_collaborations

      belongs_to :user,
                 class_name: "Decidim::User",
                 foreign_key: "decidim_user_id",
                 inverse_of: false

      enum state: [:pending, :accepted, :rejected, :paused]
      enum frequency: [:punctual, :monthly, :quarterly, :annual]

      validates :state, presence: true
      validates :frequency, presence: true
      validates :amount, presence: true, numericality: {
        greater_than: 0
      }

      scope :supported_by, ->(user) { where(user: user) }
      scope :is_accepted, -> { where(state: "accepted") }
      scope :is_pending, -> { where(state: "pending") }
      scope :recurrent, -> { where.not(frequency: "punctual") }
      scope :monthly_frequency, lambda {
        where(frequency: "monthly")
          .where(
            "last_order_request_date < ?",
            Time.zone.today.beginning_of_month
          )
      }

      scope :quarterly_frequency, lambda {
        where(frequency: "quarterly")
          .where(
            "last_order_request_date < ?",
            Time.zone.today.beginning_of_month - 2.months
          )
      }

      scope :annual_frequency, lambda {
        where(frequency: "annual")
          .where(
            "last_order_request_date < ?",
            Time.zone.today.beginning_of_month - 11.months
          )
      }

      def self.recurrent_frequencies
        frequencies.reject do |frequency|
          frequency == "punctual"
        end
      end
    end
  end
end
