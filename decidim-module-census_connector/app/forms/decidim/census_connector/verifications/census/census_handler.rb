# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        class CensusHandler < Decidim::AuthorizationHandler
          delegate :local_scope, :person_proxy, :user, to: :context
          delegate :person, :person_id, to: :person_proxy

          def handler_name
            "census"
          end

          def metadata
            {
              "person_id" => person_id
            }
          end
        end
      end
    end
  end
end
