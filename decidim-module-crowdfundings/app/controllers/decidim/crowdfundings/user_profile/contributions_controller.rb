# frozen_string_literal: true

module Decidim
  module Crowdfundings
    module UserProfile
      # Provides methods for the user to manage his recurrent contributions.
      class ContributionsController < Decidim::Crowdfundings::UserProfile::ApplicationController
        helper Decidim::Crowdfundings::ContributionsHelper
        helper_method :contributions, :contribution, :campaign,
                      :contribution_form

        def index; end

        def edit
          session[return_back_session_key] = request.referer

          enforce_permission_to :update, :contribution, contribution: contribution
        end

        def update
          enforce_permission_to :update, :contribution, contribution: contribution

          UpdateContribution.call(contribution_form) do
            on(:ok) do
              redirect_to(
                session.delete(return_back_session_key) || contribution_path,
                notice: I18n.t("decidim.crowdfundings.user_profile.contributions.update.success")
              )
            end

            on(:invalid) do
              flash.now.alert = I18n.t("decidim.crowdfundings.user_profile.contributions.update.fail")
              render :edit
            end
          end
        end

        def pause
          enforce_permission_to :update, :contribution, contribution: contribution

          UpdateContributionState.call(contribution, "paused") do
            on(:ok) do
              redirect_to contributions_path, notice: I18n.t("decidim.crowdfundings.user_profile.contributions.pause.success")
            end

            on(:ko) do
              redirect_to contributions_path, alert: I18n.t("decidim.crowdfundings.user_profile.contributions.pause.fail")
            end
          end
        end

        def resume
          enforce_permission_to :resume, :contribution, contribution: contribution

          UpdateContributionState.call(contribution, "accepted") do
            on(:ok) do
              redirect_to contributions_path, notice: I18n.t("decidim.crowdfundings.user_profile.contributions.resume.success")
            end

            on(:ko) do
              redirect_to contributions_path, alert: I18n.t("decidim.crowdfundings.user_profile.contributions.resume.fail")
            end
          end
        end

        def permission_class_chain
          [
            Decidim::Crowdfundings::Permissions,
            Decidim::Permissions
          ]
        end

        private

        def contributions
          @contributions ||= RecurrentContributions.for_user(current_user)
        end

        def contribution
          @contribution ||= Contribution.includes(:campaign).find(params[:id])
        end

        def campaign
          @campaign ||= contribution.campaign
        end

        def contribution_form
          @contribution_form ||= if params.include?(:contribution)
                                   form(Decidim::Crowdfundings::UserProfile::ContributionForm).from_params(params, **form_context)
                                 else
                                   form(Decidim::Crowdfundings::UserProfile::ContributionForm).from_model(contribution, **form_context)
                                 end
        end

        def form_context
          {
            campaign: campaign,
            contribution: contribution,
            payments_proxy: payments_proxy
          }
        end

        def return_back_session_key
          session[:"#{params[:controller]}_return_after_update"]
        end
      end
    end
  end
end
