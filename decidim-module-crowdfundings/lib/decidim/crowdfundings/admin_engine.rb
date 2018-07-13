# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # This is the engine that runs on the public interface of
    # `decidim-crowdfundings`. It mostly handles rendering
    # the campaigns associated to a Decidim participatory space.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Crowdfundings::Admin

      paths["db/migrate"] = nil

      routes do
        resources :campaigns

        root to: "campaigns#index"
      end
    end
  end
end
