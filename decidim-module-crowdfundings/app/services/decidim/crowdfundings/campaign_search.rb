# frozen_string_literal: true

module Decidim
  module Crowdfundings
    # This class handles search and filtering of campaigns. Needs a
    # `current_component` param with a `Decidim::Component` in order to
    # find the campaigns.
    class CampaignSearch < ResourceSearch
      # Public: Initializes the service.
      # component     - A Decidim::Component to get the campaigns from.
      def initialize(options = {})
        super(Campaign.all, options)
        @random_seed = options[:random_seed].to_f
      end

      # Handle the search_text filter
      def search_search_text
        query
          .where(localized_search_text_in(:title), text: "%#{search_text}%")
          .or(query.where(localized_search_text_in(:description), text: "%#{search_text}%"))
      end

      # Returns the random campaigns for the current page.
      def results
        @results ||= Campaign.transaction do
          Campaign.connection.execute("SELECT setseed(#{Campaign.connection.quote(random_seed)})")
          super.reorder(Arel.sql("RANDOM()")).load
        end
      end

      # Returns the random seed used to randomize the campaigns.
      def random_seed
        @random_seed = (rand * 2 - 1) if @random_seed == 0.0 || @random_seed > 1 || @random_seed < -1
        @random_seed
      end

      private

      # Internal: builds the needed query to search for a text in the organization's
      # available locales. Note that it is intended to be used as follows:
      #
      # Example:
      #   Resource.where(localized_search_text_for(:title, text: "my_query"))
      #
      # The Hash with the `:text` key is required or it won't work.
      def localized_search_text_in(field)
        options[:organization].available_locales.map do |l|
          "#{field} ->> '#{l}' ILIKE :text"
        end.join(" OR ")
      end
    end
  end
end