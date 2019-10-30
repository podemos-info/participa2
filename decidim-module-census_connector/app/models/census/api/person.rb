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
          send_request { get(api_url("people/#{qualified_id}"), params.slice(:version_at, :includes, :excludes)) }
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
        params[:files] = params[:files].map do |file|
          {
            filename: file.original_filename,
            content_type: file.content_type,
            base64_content: Base64.encode64(file.tempfile.read)
          }
        end

        process_response(
          send_request { post(api_url("people/#{qualified_id}/document_verifications"), params) }
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

      # PUBLIC create a cancellation procedure for the given person
      def create_cancellation(qualified_id, **params)
        process_response(
          send_request { delete(api_url("people/#{qualified_id}"), params) }
        )
      end

      # PUBLIC saves addional information for the giver person
      def save_additional_information(qualified_id, **params)
        formatted_params = {
          key: params[:key],
          json_value: params[:value].to_json
        }

        process_response(
          send_request { post(api_url("people/#{qualified_id}/additional_informations"), formatted_params) }
        )
      end
    end
  end
end
