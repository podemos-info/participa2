# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        #
        # Handles registration and verifications again the external census application
        #
        class AuthorizationsController < Decidim::CensusConnector::ApplicationController
          helper Decidim::SanitizeHelper

          before_action :authorize
          helper_method :current_form_path

          STEPS = %w(data verification membership_level).freeze

          def index
            if has_person?
              @handler = current_handler.from_model(person).with_context(form_context)
            else
              @handler = current_handler.new.with_context(form_context)
              @handler.use_default_values
            end
            render current_form
          end

          def create
            @handler = current_handler.from_params(params).with_context(form_context)
            current_command.call(census_authorization, @handler) do
              on(:ok) do
                redirect_to next_path
              end

              on(:invalid) do
                flash.now[:alert] = t("errors.create", scope: "decidim.census_connector.verifications.census")
                render current_form
              end
            end
          end

          def edit
            redirect_to decidim_census_account.root_path
          end

          def update
            create
          end

          private

          def authorize
            authorize! :manage, census_authorization
          end

          def step?
            @step ||= request[:form].blank?
          end

          def current_step
            @current_step ||= valid_step(request[:step])
          end

          def next_step
            @next_step ||= step? && STEPS[STEPS.index(current_step) + 1]
          end

          def current_form
            @current_form ||= step? ? current_step : valid_step(request[:form])
          end

          def current_handler
            @current_handler ||= "decidim/census_connector/verifications/census/#{current_form}_handler".classify.constantize
          end

          def current_command
            @current_command ||= "decidim/census_connector/verifications/census/perform_census_#{current_form}_step".classify.constantize
          end

          def next_path
            @next_path ||= if next_step
                             decidim_census.root_path(authorization_params.merge(step: next_step))
                           else
                             authorization_params[:redirect_url] || decidim_census_account.root_path
                           end
          end

          def current_form_path
            @current_form_path ||= decidim_census.authorization_path(
              authorization_params
            )
          end

          def form_context
            {
              user: current_user,
              census_qualified_id: census_qualified_id,
              local_qualified_id: local_qualified_id,
              local_scope: local_scope,
              person: person
            }
          end

          def authorization_params
            params.permit(:locale, :step, :form, :redirect_url).to_h
          end

          def valid_step(step)
            if step && STEPS.member?(step) && person_id
              step
            else
              STEPS.first
            end
          end
        end
      end
    end
  end
end
