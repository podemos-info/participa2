# frozen_string_literal: true

module Census
  module API
    # This class represents a person in Census
    class Person
      include CensusAPI

      # PUBLIC creates a person with the given params.
      def create(params)
        response = send_request do
          post("/api/v1/people", params)
        end

        @person_id = response[:person_id] if valid?(response)
      end

      # PUBLIC retrieve the available information for the given person.
      def find(**params)
        send_request do
          get("/api/v1/people/#{qualified_id}", params.slice(:version_at))
        end
      end

      # PUBLIC update the person with the given params.
      def update(params)
        response = send_request do
          patch("/api/v1/people/#{qualified_id}", params)
        end

        valid?(response)
      end

      # PUBLIC add a verification process for the person.
      def create_verification(params)
        files = params[:files].map do |file|
          {
            filename: file.original_filename,
            content_type: file.content_type,
            base64_content: Base64.encode64(file.tempfile.read)
          }
        end

        response = send_request do
          post("/api/v1/people/#{qualified_id}/document_verifications", files: files)
        end

        valid?(response)
      end

      # PUBLIC associate a membership level for the person.
      def create_membership_level(params)
        response = send_request do
          post("/api/v1/people/#{qualified_id}/membership_levels", params)
        end

        valid?(response)
      end
    end
  end
end
