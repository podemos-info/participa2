# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module CensusConnector
    # This concern add methods and helpers to simplify access to census context.
    module CensusContext
      extend ActiveSupport::Concern

      included do
        helper_method :document_scopes, :phone_scopes, :local_scope, :non_local_scope, :local_scope_ranges,
                      :has_person?, :person, :census_service?, :mandatory_census_service?

        delegate :person_id, :has_person?, :person, :service_status, to: :person_proxy, allow_nil: true
      end

      def document_scopes
        @document_scopes ||= [local_scope] + current_organization.scopes.where(parent: non_local_scope).order(name: :asc)
      end

      def phone_scopes
        @phone_scopes ||= current_organization.scopes.where(code: Phonelib.phone_data.keys).map do |scope|
          [scope, Phonelib.phone_data[scope.code]]
        end
      end

      def local_scope
        @local_scope ||= current_organization.scopes.find_by(code: Decidim::CensusConnector.census_local_code)
      end

      def non_local_scope
        @non_local_scope ||= current_organization.scopes.find_by(code: Decidim::CensusConnector.census_non_local_code)
      end

      # PUBLIC: returns a list of ranges of local scopes ids
      def local_scope_ranges
        @local_scope_ranges ||= begin
          ranges = []
          current_range = []
          local_scope.descendants.reorder(id: :asc).pluck(:id).each do |scope_id|
            if current_range.last && current_range.last + 1 != scope_id
              ranges << [current_range.first, current_range.last]
              current_range = []
            end
            current_range << scope_id
          end
          ranges << [current_range.first, current_range.last]
        end
      end

      def person_scopes
        @person_scopes ||= begin
          if has_person?
            (person.scope&.part_of || []).append(nil)
          else
            [nil]
          end
        end
      end

      def person_participatory_spaces
        @person_participatory_spaces ||= Decidim.participatory_space_registry.manifests.flat_map do |participatory_space_manifest|
          participatory_space_model = participatory_space_manifest.model_class_name.constantize
          next unless participatory_space_model.columns_hash["decidim_scope_id"]

          participatory_space_model.published.where(decidim_scope_id: person_scopes)
        end.compact.sort_by(&:id)
      end

      def census_service?
        service_status != false
      end

      def mandatory_census_service?
        service_status(force_check: true) == true
      end

      def person_proxy
        @person_proxy ||= Decidim::CensusConnector::PersonProxy.for(current_user, user_request: request) if current_user
      end
    end
  end
end
