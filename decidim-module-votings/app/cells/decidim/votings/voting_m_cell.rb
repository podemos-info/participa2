# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Votings
    # This cell renders a voting with its M-size card.
    class VotingMCell < Decidim::CardMCell
      include VotingCellsHelper

      def voting
        model
      end

      private

      def title
        translated_attribute model.title
      end

      def description
        html_truncate(translated_attribute(model.description), max_length: 200)
      end

      def has_image?
        true
      end

      def resource_image_path
        model.image.url
      end

      def statuses
        [:voted, :next_date]
      end

      def next_date_status
        render :next_date
      end

      def voted_status
        render :voted
      end

      def vote_permission_descriptions
        @vote_permission_descriptions ||= vote_action_authorizer_class&.try(:describe_options, vote_permission_options)
      end

      def current_component
        model.component
      end

      def has_voted?
        @has_voted ||= model.has_voted?(current_user)
      end

      def next_date
        if voting.started?
          model.end_date
        else
          model.start_date
        end
      end

      def vote_action
        if has_voted?
          :change_vote
        else
          :vote
        end
      end

      def vote_action_authorizer_class
        return unless vote_authorization_handler_name

        @vote_action_authorizer_class ||= Verifications.find_workflow_manifest(vote_authorization_handler_name)&.action_authorizer_class
      end

      def vote_authorization_handler_name
        vote_permission&.fetch("authorization_handler_name", nil)
      end

      def vote_permission_options
        vote_permission&.fetch("options", {})
      end

      def vote_permission
        @vote_permission ||= model.permissions&.fetch("vote", nil) || current_component.permissions&.fetch("vote", nil)
      end

      def vote_path
        ::Decidim::EngineRouter.main_proxy(current_component).voting_vote_path(voting.id)
      end
    end
  end
end
