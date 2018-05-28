# frozen_string_literal: true

module Decidim
  module Collaborations
    module Admin
      # This command contains all common methods for all collaboration related
      # commands
      class CollaborationCommand < Rectify::Command
        attr_reader :form

        def initialize(form)
          @form = form
        end

        protected

        def amounts
          form.amounts.split(",").map(&:to_i).uniq.sort { |a, b| a - b }
        end
      end
    end
  end
end
