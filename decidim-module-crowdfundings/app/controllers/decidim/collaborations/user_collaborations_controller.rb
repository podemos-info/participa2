# frozen_string_literal: true

module Decidim
  module Collaborations
    # Controller responsible of managing user collaborations
    class UserCollaborationsController < Decidim::Collaborations::ApplicationController
      include NeedsCollaboration
      include CensusAPI

      def create
        @form = confirmed_collaboration_form
                .from_params(params, collaboration: collaboration)
        CreateUserCollaboration.call(@form) do
          on(:ok) do
            successful_creation
          end

          on(:credit_card) do |census|
            credit_card_creation(census[:form])
          end

          on(:invalid) do
            invalid_creation
          end
        end
      end

      # Marks the given collaboration as accepted or rejected,
      # depending on the response response received through the
      # result attribute
      def validate
        accept_user_collaboration if params[:result] == "ok"
        reject_user_collaboration if params[:result] == "ko"

        redirect_to EngineRouter.main_proxy(current_component)
                                .collaboration_path(user_collaboration.collaboration)
      end

      def accept_user_collaboration
        user_collaboration.update(state: "accepted")
        flash[:notice] = I18n.t(
          "user_collaborations.validate.success",
          scope: "decidim.collaborations"
        )
      end

      def reject_user_collaboration
        user_collaboration.update(state: "rejected")
        flash[:alert] = I18n.t(
          "user_collaborations.validate.invalid",
          scope: "decidim.collaborations"
        )
      end

      def confirm
        @form = collaboration_form
                .from_params(params, collaboration: collaboration)

        if @form.valid?
          @form = confirmed_collaboration_form
                  .from_params(params, collaboration: collaboration)
          @form.correct_payment_method
        else
          render "/decidim/collaborations/collaborations/show"
        end
      end

      private

      def invalid_creation
        flash.now[:alert] = I18n.t(
          "user_collaborations.create.invalid",
          scope: "decidim.collaborations"
        )
        render action: "confirm"
      end

      def successful_creation
        flash[:notice] = I18n.t(
          "user_collaborations.create.success",
          scope: "decidim.collaborations"
        )

        redirect_to EngineRouter.main_proxy(current_component)
                                .collaboration_path(collaboration)
      end

      def credit_card_creation(form_data)
        @census = form_data
        render "/decidim/collaborations/user_collaborations/census_credit_card"
      end

      def user_collaboration
        @user_collaboration ||= UserCollaboration.find(params[:id])
      end

      def collaboration_form
        form(Decidim::Collaborations::UserCollaborationForm)
      end

      def confirmed_collaboration_form
        form(Decidim::Collaborations::ConfirmUserCollaborationForm)
      end
    end
  end
end
