# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        #
        # Handles registration and verifications again the external census application
        #
        class AuthorizationsController < Decidim::CensusConnector::ApplicationController
          helper Decidim::CensusConnector::AuthorizationsHelper
          helper Decidim::SanitizeHelper

          helper_method :form, :step_path

          STEPS = %w(data phone_verification verification).freeze

          def index
            @form = if has_person?
                      form_class.from_model(person).with_context(form_context)
                    else
                      form_class.new.with_context(form_context)
                    end

            render step
          end

          def create
            command_class.call(person_proxy, form) do
              on(:ok) do
                redirect_to next_path
              end
              on(:invalid) do
                flash.now[:alert] = t("messages.invalid", scope: "census.api")
                render step
              end
              on(:error) do
                flash.now[:error] = t("messages.error", scope: "census.api")
                render step
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

          def step
            @step ||= valid_step(request[:step])
          end

          def step_path
            @step_path ||= decidim_census.authorization_path(authorization_params)
          end

          def form
            @form ||= form_class.from_params(params).with_context(form_context)
          end

          def form_class
            @form_class ||= "decidim/census_connector/verifications/census/#{step}_form".classify.constantize
          end

          def command_class
            @command_class ||= "decidim/census_connector/verifications/census/perform_census_#{step}_step".classify.constantize
          end

          def next_path
            if form.next_step
              decidim_census.root_path(authorization_params.merge(step: form.next_step, **form.next_step_params))
            else
              authorization_params[:redirect_url] || decidim_census_account.root_path
            end
          end

          def form_context
            {
              local_scope: local_scope,
              person: person,
              params: params
            }
          end

          def authorization_params
            params.permit(:locale, :step, :redirect_url, :part, :phone).to_h
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
