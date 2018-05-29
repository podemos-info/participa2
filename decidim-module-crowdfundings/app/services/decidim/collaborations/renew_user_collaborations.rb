# frozen_string_literal: true

module Decidim
  module Collaborations
    # Class responsible of renewing a set of user
    # collaborations
    class RenewUserCollaborations
      # Sugar syntax that executes the the renew process
      # for all frequencies
      def self.run
        new(PendingAnnualCollaborations.new).run
        new(PendingQuarterlyCollaborations.new).run
        new(PendingMonthlyCollaborations.new).run
      end

      # Initializes the service with the list of
      # user collaborations that need to be renewed.
      def initialize(user_collaborations)
        @user_collaborations = user_collaborations
      end

      # Executes the renew process
      def run
        user_collaborations.each do |user_collaboration|
          RenewUserCollaboration.new(user_collaboration).call
        end
      end

      private

      attr_reader :user_collaborations
    end
  end
end
