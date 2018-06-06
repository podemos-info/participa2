# frozen_string_literal: true

module Decidim
  module Collaborations
    module UserProfile
      # Provides methods for the user to manage his recurrent collaborations.
      class UserCollaborationsController < Decidim::Collaborations::UserProfile::ApplicationController
        helper_method :collaborations, :user_collaboration, :collaboration,
                      :user_collaboration_form

        def index; end

        def edit
          session[return_back_session_key] = request.referer

          enforce_permission_to :update, :user_collaboration, user_collaboration: user_collaboration
        end

        def update
          enforce_permission_to :update, :user_collaboration, user_collaboration: user_collaboration

          UpdateUserCollaboration.call(form_from_params) do
            on(:ok) do
              redirect_to(
                session.delete(return_back_session_key) || user_collaborations_path,
                notice: I18n.t("decidim.collaborations.user_profile.user_collaborations.update.success")
              )
            end

            on(:invalid) do |form|
              flash.now.alert = I18n.t("decidim.collaborations.user_profile.user_collaborations.update.fail")
              render action: :edit, locals: { user_collaboration_form: form }
            end
          end
        end

        def pause
          enforce_permission_to :update, :user_collaboration, user_collaboration: user_collaboration

          UpdateUserCollaborationState.call(user_collaboration, "paused") do
            on(:ok) do
              redirect_to user_collaborations_path, notice: I18n.t("decidim.collaborations.user_profile.user_collaborations.pause.success")
            end

            on(:ko) do
              redirect_to user_collaborations_path, alert: I18n.t("decidim.collaborations.user_profile.user_collaborations.pause.fail")
            end
          end
        end

        def resume
          enforce_permission_to :resume, :user_collaboration, user_collaboration: user_collaboration

          UpdateUserCollaborationState.call(user_collaboration, "accepted") do
            on(:ok) do
              redirect_to user_collaborations_path, notice: I18n.t("decidim.collaborations.user_profile.user_collaborations.resume.success")
            end

            on(:ko) do
              redirect_to user_collaborations_path, alert: I18n.t("decidim.collaborations.user_profile.user_collaborations.resume.fail")
            end
          end
        end

        private

        def collaborations
          @collaborations ||= RecurrentCollaborations.for_user(current_user)
        end

        def user_collaboration
          @user_collaboration ||= UserCollaboration.includes(:collaboration).find(params[:id])
        end

        def collaboration
          @collaboration ||= user_collaboration.collaboration
        end

        def user_collaboration_form
          form(Decidim::Collaborations::UserProfile::UserCollaborationForm).from_model(
            user_collaboration,
            collaboration: user_collaboration.collaboration
          )
        end

        def form_from_params
          form(Decidim::Collaborations::UserProfile::UserCollaborationForm)
            .from_params(params,
                         collaboration: collaboration,
                         user_collaboration: user_collaboration)
        end

        def return_back_session_key
          session[:"#{params[:controller]}_return_after_update"]
        end
      end
    end
  end
end
