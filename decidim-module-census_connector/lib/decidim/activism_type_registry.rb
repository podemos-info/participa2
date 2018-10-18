# frozen_string_literal: true

module Decidim
  module CensusConnector
    # This class acts as a registry for types of activism
    class ActivismTypeRegistry
      # Public: Registers a type of activism
      #
      # name - a symbol or string representing the activism type.
      # &block - The block that calculates a person activism status for an activism type.
      #
      # Returns nothing.
      def register_activism_type(name, order: 0, &block)
        activism_types[name.to_sym] = {
          order: order,
          block: block
        }
      end

      # Public: Calculate the activism status of a person for all registered activism types.
      def activism_types_status_for(person, context)
        activism_types.values.sort_by { |activism_type| activism_type[:order] }.map do |activism_type|
          ActivismTypeStatus.new(**context.instance_exec(person, &activism_type[:block]))
        end.select(&:valid?)
      end

      class ActivismTypeStatus
        attr_accessor :active, :title, :status_text, :status_icon_params, :edit_text, :edit_link

        def initialize(**params)
          @active = params[:active]
          @title = params[:title]
          @status_text = params[:status_text]
          @status_icon_params = params[:status_icon_params]
          @edit_text = params[:edit_text]
          @edit_link = params[:edit_link]
        end

        def valid?
          [@active, @title, @status_text, @status_icon_params, @edit_text, @edit_link].none?(&:nil?)
        end
      end

      private

      def activism_types
        @activism_types ||= {}
      end
    end
  end
end
