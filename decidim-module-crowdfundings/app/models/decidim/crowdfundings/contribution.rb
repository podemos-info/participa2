# frozen_string_literal: true

module Decidim
  module Crowdfundings
    class Contribution < Decidim::Crowdfundings::ApplicationRecord
      belongs_to :campaign,
                 class_name: "Decidim::Crowdfundings::Campaign",
                 foreign_key: "decidim_crowdfundings_campaign_id",
                 touch: true,
                 inverse_of: :contributions

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

      scope :active, -> { where(state: [:pending, :accepted]) }
      scope :supported_by, ->(user) { where(user: user) }
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

      def recurrent?
        !punctual?
      end
    end
  end
end
