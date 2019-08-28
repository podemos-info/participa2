# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Seeds
      class Users
        def initialize(organization)
          @organization = organization
        end

        attr_accessor :organization

        def seed(_options)
          puts "Loading admin users..."
          (1..5).each { |id| synchronize_user(id, true) }

          puts "Loading regular users..."
          (6..50).each { |id| synchronize_user(id, false) }
        end

        private

        def synchronize_user(id, admin)
          ret, person_data = Census::API::Person.new(nil).find("#{id}@census")
          return unless ret == :ok && person_data&.fetch(:email, nil)

          user = Decidim::User.find_or_initialize_by(id: person_data[:external_ids][:decidim])
          person = Decidim::CensusConnector::Person.new(user, person_data.deep_stringify_keys)

          user.update!(
            admin: admin,
            email: person.email,
            name: person.first_name,
            nickname: "#{person.first_name} #{person.last_name1.strip[0].upcase}.",
            password: user.password_confirmation = person.email.split("@").first.downcase + "participa2",
            confirmed_at: Time.zone.now,
            locale: I18n.default_locale,
            organization: organization,
            tos_agreement: true
          )

          authorization = Decidim::Authorization.find_or_initialize_by(
            user: user,
            name: "census"
          )

          authorization.update!(
            metadata: person_attributes_hash(person, [:state, :person_id, :scope_code, :verification, :membership_level, :document_type, :age])
          )
        end

        def person_attributes_hash(person, attributes)
          attributes.each_with_object({}) do |object, attribute|
            object[attribute] = person.send(attribute)
          end
        end
      end
    end
  end
end
