# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        class VerificationForm < Decidim::Form
          attribute :document_file1
          attribute :document_file2

          attribute :member, Boolean

          attribute :received_code, String

          attribute :tos_agreement, Boolean

          validates :tos_agreement, allow_nil: true, acceptance: true

          def map_model(person)
            @member = person.member?
          end

          def information_page
            @information_page ||= Decidim::StaticPage.find_by(slug: "verification-information")
          end

          def terms_and_conditions_page
            @terms_and_conditions_page ||= Decidim::StaticPage.find_by(slug: "verification-terms-and-conditions")
          end

          def files
            [document_file1, document_file2].compact
          end

          def level
            member ? :member : :follower
          end

          def identity_part?
            !verified? && (part.blank? || !phone_part?)
          end

          def membership_part?
            part.blank? || part == "membership"
          end

          def phone_part?
            part == "phone"
          end

          def pretty_phone
            "(+#{parsed_phone.country_code}) #{parsed_phone.national}"
          end

          def member
            @member.presence || true
          end

          private

          delegate :person, :part, to: :context

          def parsed_phone
            @parsed_phone ||= Phonelib.parse(person.phone)
          end

          def verified?
            @verified ||= person.verified?
          end
        end
      end
    end
  end
end
