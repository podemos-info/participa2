# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HeroCell < Decidim::ViewModel
      include Decidim::SanitizeHelper

      delegate :current_organization, :current_user, :has_person?, :person, :decidim_census, :decidim_census_account, to: :controller

      # Needed so that the `CtaButtonHelper` can work.
      def decidim_participatory_processes
        Decidim::ParticipatoryProcesses::Engine.routes.url_helpers
      end

      def background_image
        model.images_container.background_image.big.url
      end

      def title_text
        if person_status
          t("decidim.content_blocks.hero.#{person_status}.title")
        elsif translated_welcome_text.blank?
          t("decidim.pages.home.hero.welcome", organization: current_organization.name)
        else
          decidim_sanitize(translated_welcome_text)
        end
      end

      # Renders the Call To Action button. Link and text can be configured
      # per organization.
      def button_text
        if person_status
          t("decidim.content_blocks.hero.#{person_status}.button")
        else
          translated_attribute(current_organization.cta_button_text).presence || t("decidim.pages.home.hero.participate")
        end
      end

      # Finds the CTA button path to reuse it in other places.
      def button_path
        case person_status
        when false
          current_organization.cta_button_path.presence || decidim.new_user_registration_path
        when :no_person then decidim_census.root_path
        else decidim_census_account.root_path
        end
      end

      private

      def translated_welcome_text
        @translated_welcome_text ||= translated_attribute(model.settings.welcome_text)
      end

      def person_status
        @person_status ||= if !current_user
                             false
                           elsif !has_person?
                             :no_person
                           elsif !person.verified?
                             :no_verified
                           else
                             :verified
                           end
      end
    end
  end
end
