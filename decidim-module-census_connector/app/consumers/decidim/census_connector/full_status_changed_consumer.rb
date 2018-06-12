# frozen_string_literal: true

module Decidim
  module CensusConnector
    class FullStatusChangedConsumer
      include ::Hutch::Consumer
      consume "census.people.full_status_changed"

      def process(message)
        params = prepare_message(message)
        authorization = Decidim::Authorization.find_by("metadata->>'person_id' = ?", params["person_id"].to_s)
        return unless authorization

        authorization.metadata.merge!(params)
        authorization.save!
      end

      private

      def prepare_message(message)
        ret = message.body
        ret["person_id"] = ret.delete("person").split("@").first.to_i
        ret
      end
    end
  end
end
