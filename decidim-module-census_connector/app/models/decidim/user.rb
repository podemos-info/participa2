# frozen_string_literal: true

# This override makes Decidim::User to allow users to login with their document id

require File.expand_path("../../../app/models/decidim/user", Decidim::Core::Engine.called_from)

module Decidim
  User.class_eval do
    class << self
      def find_for_database_authentication(warden_conditions)
        conditions = warden_conditions.dup
        email_from_document_id(conditions)
        find_for_authentication(conditions)
      end

      private

      def email_from_document_id(conditions)
        return unless document_id?(conditions[:email])

        result, info = ::Census::API::Person.new(nil).find("#{conditions[:email]}@document_id", includes: [:email])
        conditions[:email] = info[:email] if result == :ok
      end

      def document_id?(identifier)
        identifier.index("@").nil?
      end
    end
  end
end
