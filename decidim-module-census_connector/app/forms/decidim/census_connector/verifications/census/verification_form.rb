# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        class VerificationForm < Decidim::Form
          attribute :document_file1
          attribute :document_file2

          attribute :member, Boolean

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

          def target_level
            return :follower unless membership_allowed?

            member.presence ? :member : :follower
          end

          def full_process?
            part.blank?
          end

          def identity_part?
            !verified?
          end

          def membership_action?
            part == "membership"
          end

          def action
            return :verify unless membership_allowed? && membership_action?

            member? ? :to_follower : :to_member
          end

          def changing_membership_level?
            target_level != person.membership_level
          end

          def next_step; end

          def next_step_params
            { part: part }
          end

          delegate :member?, :membership_allowed?, to: :person

          private

          delegate :person, :params, to: :context

          def verified?
            @verified ||= person.verified?
          end

          def part
            @part ||= params[:part]
          end
        end
      end
    end
  end
end
