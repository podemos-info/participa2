# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Account
      class AccountController < Decidim::CensusConnector::ApplicationController
        include Decidim::UserProfile

        helper_method :person_presenter

        def index
          @person_presenter = AccountPresenter.new(person, context: self)
        end

        private

        attr_reader :person_presenter
      end
    end
  end
end
