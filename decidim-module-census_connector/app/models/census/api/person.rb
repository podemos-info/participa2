# frozen_string_literal: true

module Census
  module API
    # This class represents a person in Census
    class Person
      include CensusAPI

      # PUBLIC creates a person with the given params.
      def self.create(params)
        response = send_request do
          post("/api/v1/people", body: params)
        end
        response[:person_id]
      end

      attr_reader :qualified_id

      def initialize(person_id)
        @qualified_id = "#{person_id}@census"
      end

      # PUBLIC retrieve the available information for the given person.
      def find
        send_request do
          get("/api/v1/people/#{qualified_id}")
        end
      end

      # PUBLIC update the person with the given params.
      def update(params)
        send_request do
          patch("/api/v1/people/#{qualified_id}", body: params)
        end
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
    end
  end
end
