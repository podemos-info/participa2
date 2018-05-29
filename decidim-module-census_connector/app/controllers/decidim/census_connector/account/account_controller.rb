# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Account
      class AccountController < Decidim::CensusConnector::ApplicationController
        include Decidim::UserProfile
        skip_authorization_check

        helper_method :person_presenter
        attr_reader :person_presenter

        def index
          @person_presenter = AccountPresenter.new(person)
        end
      end
    end
  end
end
