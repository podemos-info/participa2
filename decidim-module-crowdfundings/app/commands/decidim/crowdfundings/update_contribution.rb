# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # Rectify command that creates a contribution
    class UpdateContribution < Rectify::Command
      attr_reader :form

      def initialize(form)
        @form = form
      end

      # Updates the contribution if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) unless form.valid? && update_contribution
        broadcast(:ok)
      end

      private

      delegate :contribution, to: :form

      def update_contribution
        contribution.update(
          frequency: form.frequency,
          amount: form.amount,
          **resume_contribution
        )
      end

      def resume_contribution
        if contribution.paused? && form.resume
          { state: "accepted" }
        else
          {}
        end
      end
    end
  end
end
