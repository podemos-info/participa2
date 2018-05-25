# frozen_string_literal: true

module Census
  module API
    # This class represents a person in Census
    class Person
      include CensusAPI

      attr_reader :person_id, :errors

      def initialize(person_id)
        @person_id = person_id
      end

      # PUBLIC creates a person with the given params.
      def create(params)
        response = send_request do
          post("/api/v1/people", body: params)
        end

        result = valid?(response)

        @person_id = response[:person_id]

        result
      end

      # PUBLIC retrieve the available information for the given person.
      def find
        send_request do
          get("/api/v1/people/#{qualified_id}")
        end
      end

      # PUBLIC update the person with the given params.
      def update(params)
        response = send_request do
          patch("/api/v1/people/#{qualified_id}", body: params)
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

        send_request do
          post("/api/v1/people/#{qualified_id}/document_verifications", body: { files: files })
        end
      end

      # PUBLIC associate a membership level for the person.
      def create_membership_level(params)
        send_request do
          post("/api/v1/people/#{qualified_id}/membership_levels", body: params)
        end
      end

      private

      def qualified_id
        "#{person_id}@census"
      end

      def valid?(response)
        http_response_code = response.delete(:http_response_code)

        if [202, 204].include?(http_response_code)
          true
        else
          @errors = response

          false
        end
      end
    end
  end
end
