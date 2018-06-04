# frozen_string_literal: true

module Census
  module API
    # This class represents a person in Census
    class Person
      include CensusAPI

      attr_reader :person_id, :errors, :global_error

      def initialize(person_id)
        @person_id = person_id
      end

      # PUBLIC creates a person with the given params.
      def create(params)
        response = send_request do
          post("/api/v1/people", params)
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

      # PUBLIC retrieve pending procedures for the person.
      def pending_procedures
        response = send_request do
          get("/api/v1/people/#{qualified_id}/procedures")
        end

        status = response.delete(:http_response_code)

        return [] unless status == 200

        response
      end

      private

      def qualified_id
        "#{person_id}@census"
      end

      def valid?(response)
        http_response_code = response.delete(:http_response_code)

        if [202, 204].include?(http_response_code)
          true
        elsif http_response_code == 422
          @errors = response

          false
        else
          @global_error = I18n.t("census.api.global_error")

          false
        end
      end
    end
  end
end
