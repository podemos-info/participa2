# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Account
      # A presenter to render account info
      class AccountPresenter
        include Decidim::TranslationsHelper

        def initialize(person, context:)
          @person = person
          @context = context
        end

        def full_name
          [person.first_name, person.last_name1, person.last_name2].reject(&:blank?).join " "
        end

        def full_document
          ret = "#{I18n.t(person.document_type, scope: "census.api.person.document_type")} - #{person.document_id}"
          ret += " (#{translated_attribute(@person.document_scope.name)})" unless Person.local_document?(person.document_type)
          ret
        end

        def born_at
          I18n.l(person.born_at, format: :default)
        end

        def gender
          I18n.t(person.gender, scope: "census.api.person.gender")
        end

        def full_address
          "#{person.address} - #{person.postal_code}"
        end

        def participation_scope
          ret = translated_attribute(person.address_scope.name)
          ret += " (#{translated_attribute(person.scope.name)})" unless person.address_scope_id == person.scope_id
          ret
        end

        def membership_level
          I18n.t(
            person.membership_allowed? ? person.membership_level : "not_allowed",
            scope: "census.api.person.membership_level"
          )
        end

        def verification_icon_params
          case person.verification
          when "not_verified"
            ["x", class: "muted"]
          when "verification_requested"
            ["warning", class: "warning"]
          when "verification_received"
            ["timer", class: "warning"]
          when "verified"
            ["check", class: "success"]
          end
        end

        def phone_verification_icon_params
          case person.phone_verification
          when "not_verified"
            ["x", class: "muted"]
          when "reassigned"
            ["warning", class: "warning"]
          when "verified"
            ["check", class: "success"]
          end
        end

        def membership_level_icon_params
          return ["ban", class: "muted"] unless person.membership_allowed?

          case person.membership_level
          when "follower"
            ["x", class: "muted"]
          when "member"
            ["check", class: "success"]
          end
        end

        def pretty_phone
          "(+#{parsed_phone.country_code}) #{parsed_phone.raw_national}"
        end

        def activism_active?
          @activism_active ||= activism_types_status.any?(&:active)
        end

        def activism_status
          if activism_active?
            :activist
          else
            :not_activist
          end
        end

        def activism_icon_params
          if activism_active?
            ["check", class: "success"]
          else
            ["x", class: "muted"]
          end
        end

        def activism_types_status
          @activism_types_status ||= Decidim::CensusConnector.activism_types.activism_types_status_for(person, @context)
        end

        def social_networks
          @social_networks ||= Hash[
            Decidim::CensusConnector.social_networks.map do |network, info|
              nickname = @person.additional_information[:"social_network_#{network}"]
              [network, { name: info[:name], nickname: nickname, link: format(info[:url], nickname: nickname) }] if nickname
            end.compact
          ]
        end

        private

        attr_reader :person

        def parsed_phone
          @parsed_phone ||= Phonelib.parse(person.phone)
        end
      end
    end
  end
end
