# frozen_string_literal: true

module Decidim
  module CensusConnector
    class ApplicationConsumer
      def parse_external_ids(external_ids)
        external_ids.map do |organization, user_id|
          organization_id = organization.scan(/^#{Rails.application.engine_name}-(\d+)$/)
          [organization_id.flatten.first.to_i, user_id] if organization_id.any?
        end.compact.to_h
      end
    end
  end
end
