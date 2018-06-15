# frozen_string_literal: true

module Decidim
  module GravityForms
    # This is the engine that runs on the public interface of `GravityForms`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::GravityForms::Admin

      paths["db/migrate"] = nil

      routes do
        resources :gravity_forms
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        root to: "gravity_forms#index"
      end

      def load_seed
        nil
      end
    end
  end
end
