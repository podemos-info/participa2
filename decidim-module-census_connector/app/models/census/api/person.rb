# frozen_string_literal: true

module Census
  module API
    # This class represents a person in Census
    class Person
      include CensusAPI

      # PUBLIC creates a person with the given params.
      def create(params)
        process_response(
          send_request { post(api_url("people"), params) }
        ) do |response|
          response[:person_id]
        end
      end

      # PUBLIC retrieve the available information for the given person.
      def find(qualified_id, **params)
        process_response(
          send_request { get(api_url("people/#{qualified_id}"), params.slice(:version_at)) }
        )
      end

      # PUBLIC update the person with the given params.
      def update(qualified_id, **params)
        process_response(
          send_request { patch(api_url("people/#{qualified_id}"), params) }
        )
      end

      # PUBLIC add a verification process for the person.
      def create_verification(qualified_id, **params)
        files = params[:files].map do |file|
          {
            filename: file.original_filename,
            content_type: file.content_type,
            base64_content: Base64.encode64(file.tempfile.read)
          }
        end

        process_response(
          send_request { post(api_url("people/#{qualified_id}/document_verifications"), files: files) }
        )
      end

      # PUBLIC associate a membership level for the person.
      def create_membership_level(qualified_id, **params)
        process_response(
          send_request { post(api_url("people/#{qualified_id}/membership_levels"), params) }
        )
      end

      # PUBLIC start a phone verification for the person.
      def start_phone_verification(qualified_id, **params)
        process_response(
          send_request { get(api_url("people/#{qualified_id}/phone_verifications/new"), params) }
        )
      end

      # PUBLIC complete a phone verification for the person.
      def create_phone_verification(qualified_id, **params)
        process_response(
          send_request { post(api_url("people/#{qualified_id}/phone_verifications"), params) }
        )
      end
    end
  end
end
