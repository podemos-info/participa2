# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      class VotingsController < Admin::ApplicationController
        helper Decidim::Votings::Admin::VotingsHelper
        helper Decidim::Votings::VotingsHelper
        helper Decidim::DecidimFormHelper

        def new
          @form = voting_form.instance
        end

        def create
          @form = voting_form.from_params(params)

          CreateVoting.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("votings.create.success", scope: "decidim.votings.admin")
              redirect_to votings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("votings.create.invalid", scope: "decidim.votings.admin")
              render action: "new"
            end
          end
        end

        def edit
          @form = voting_form.from_model(voting)
          @voting = voting
        end

        def update
          @form = voting_form.from_params(params)

          UpdateVoting.call(@form, voting) do
            on(:ok) do
              flash[:notice] = I18n.t("votings.update.success", scope: "decidim.votings.admin")
              redirect_to votings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("votings.update.invalid", scope: "decidim.votings.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :voting, voting: voting
          voting.destroy!
          flash[:notice] = I18n.t("votings.destroy.success", scope: "decidim.votings.admin")
          redirect_to votings_path
        end

        private

        def voting_form
          form(VotingForm)
        end
      end
    end
  end
end
