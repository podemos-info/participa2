# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Seeds
      class Users
        def initialize(organization)
          @organization = organization
        end

        attr_accessor :organization

        def seed(*_args)
          puts "Loading admin users..."
          (1..5).each { |id| synchronize_user(id, true) }

          puts "Loading regular users..."
          (6..50).each { |id| synchronize_user(id, false) }

          max_id = Decidim::User.maximum(:id)
          Decidim::User.connection.execute(ActiveRecord::Base.send(:sanitize_sql_array, ["ALTER SEQUENCE decidim_users_id_seq RESTART WITH ?", max_id + 1]))
        end

        private

        def synchronize_user(id, admin)
          ret, person_data = Census::API::Person.new(nil).find("#{id}@census")
          return unless ret == :ok && person_data&.fetch(:email, nil)

          user_id = person_data[:external_ids][:"#{Rails.application.engine_name}-#{organization.id}"]
          puts "User ID not found for person #{person_data[:person_id]}." && return unless user_id

          user = Decidim::User.find_or_initialize_by(id: user_id)
          person = Decidim::CensusConnector::Person.new(user, person_data.deep_stringify_keys)

          password = person.email.split("@").first.downcase + "participa2"
          user.update!(
            admin: admin,
            email: person.email,
            name: person.first_name,
            nickname: "#{person.first_name} #{person.last_name1.strip[0].upcase}.",
            password: password,
            password_confirmation: password,
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
          attributes.each_with_object({}) do |attribute, object|
            object[attribute] = person.send(attribute)
          end
        end
      end
    end
  end
end
