# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        # This is an engine that performs user authorizations against Podemos census application.
        class Engine < ::Rails::Engine
          isolate_namespace Decidim::CensusConnector::Verifications::Census

          paths["db/migrate"] = nil

          routes do
            resource :authorizations, only: [:index, :create, :edit, :update], as: :authorization

            root to: "authorizations#index"
          end
        end
      end
    end
  end
end
