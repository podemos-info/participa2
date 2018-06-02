# frozen_string_literal: true

module Decidim
  module CensusConnector
    module Verifications
      module Census
        class VerificationForm < Decidim::Form
          attribute :document_file1
          attribute :document_file2
          attribute :tos_agreement, Boolean

          validates :tos_agreement, allow_nil: true, acceptance: true

          def information_page
            @information_page ||= Decidim::StaticPage.find_by(slug: "verification-information")
          end

          def terms_and_conditions_page
            @terms_and_conditions_page ||= Decidim::StaticPage.find_by(slug: "verification-terms-and-conditions")
          end

          def files
            [document_file1, document_file2].compact
          end
        end
      end
    end
  end
end
