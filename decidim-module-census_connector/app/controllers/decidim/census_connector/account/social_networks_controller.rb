# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Account
      class SocialNetworksController < Decidim::CensusConnector::ApplicationController
        include Decidim::UserProfile

        helper_method :person_presenter, :form

        def create
          StoreSocialNetwork.call(person_proxy, form) do
            on(:ok) do
              form.reset
              flash.now[:success] = t("social_networks.messages.saved", scope: "decidim.census_connector.account")
            end
            on(:invalid) do
              flash.now[:alert] = t("messages.invalid", scope: "census.api")
            end
            on(:error) do
              flash.now[:error] = t("messages.error", scope: "census.api")
            end
          end
          render :index
        end

        def destroy
          DeleteSocialNetwork.call(person_proxy, delete_form) do
            on(:ok) do
              flash.now[:success] = t("social_networks.messages.deleted", scope: "decidim.census_connector.account")
            end
            on(:invalid) do
              flash.now[:alert] = t("messages.invalid", scope: "census.api")
            end
            on(:error) do
              flash.now[:error] = t("messages.error", scope: "census.api")
            end
          end
          render :index
        end

        private

        def form
          @form ||= Decidim::CensusConnector::Account::SocialNetworkForm.from_params(params)
        end

        def delete_form
          @delete_form ||= Decidim::CensusConnector::Account::DeleteSocialNetworkForm.from_params(network: params[:id])
        end

        def person_presenter
          @person_presenter ||= AccountPresenter.new(person, context: self)
        end
      end
    end
  end
end
