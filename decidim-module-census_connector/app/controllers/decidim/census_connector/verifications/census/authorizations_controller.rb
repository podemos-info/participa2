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

          helper_method :current_form_path

          STEPS = %w(data verification membership_level).freeze

          def index
            @form = if has_person?
                      current_form_object.from_model(person).with_context(form_context)
                    else
                      current_form_object.new.with_context(form_context)
                    end

            render current_form
          end

          def create
            @form = current_form_object.from_params(params).with_context(form_context)
            current_command.call(person_proxy, @form) do
              on(:ok) do
                redirect_to next_path
              end

              on(:invalid) do |message|
                flash.now[:alert] = message || t("errors.create", scope: "decidim.census_connector.verifications.census")
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

          def current_form_object
            @current_form_object ||= "decidim/census_connector/verifications/census/#{current_form}_form".classify.constantize
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
              local_scope: local_scope
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
