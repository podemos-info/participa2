# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Account
      # A presenter to render account info
      class AccountPresenter
        include Decidim::TranslationsHelper

        def initialize(person)
          @person = person
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
          I18n.t(person.membership_level, scope: "census.api.person.membership_level")
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

        def membership_level_icon_params
          case person.membership_level
          when "follower"
            ["x", class: "muted"]
          when "member"
            ["check", class: "success"]
          end
        end

        def pretty_phone
          "(+#{parsed_phone.country_code}) #{parsed_phone.national}"
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
