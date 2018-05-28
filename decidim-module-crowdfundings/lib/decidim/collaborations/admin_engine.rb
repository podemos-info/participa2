# frozen_string_literal: true

module Decidim
  module Collaborations
    # This is the engine that runs on the public interface of
    # `decidim-collaborations`. It mostly handles rendering
    # the collaborations associated to a participatory Decidimprocess.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Collaborations::Admin

      paths["db/migrate"] = nil

      routes do
        resources :collaborations

        root to: "collaborations#index"
      end
    end
  end
end
