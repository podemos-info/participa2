# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Collaborations
    # This cell renders a collaboration with its M-size card.
    class CollaborationMCell < Decidim::CardMCell
      include CollaborationCellsHelper

      private

      def title
        translated_attribute model.title
      end

      def description
        translated_attribute model.description
      end

      def has_amount?
        model.target_amount.present?
      end
    end
  end
end
