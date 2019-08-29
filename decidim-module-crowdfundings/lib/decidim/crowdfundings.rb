# frozen_string_literal: true

require "decidim/crowdfundings/engine"
require "decidim/crowdfundings/admin"
require "decidim/crowdfundings/admin_engine"
require "decidim/crowdfundings/user_profile"
require "decidim/crowdfundings/user_profile_engine"
require "decidim/crowdfundings/component"
require "decidim/crowdfundings/form_builder"
require "iban_bic"

module Decidim
  # Base module for this engine.
  module Crowdfundings
    include ActiveSupport::Configurable

    # Public setting that defines the maximum annual contribution
    # amount for an user.
    config_accessor :maximum_annual_contribution_amount do
      10_000
    end

    # Amounts offered to the user for contributing with a
    # participatory space.
    config_accessor :selectable_amounts do
      [25, 50, 100, 250, 500]
    end

    # Number of campaigns shown per page in administrator
    # dashboard
    config_accessor :campaigns_shown_per_page do
      15
    end

    # Public Setting that defines how many campaigns will be shown in the
    # participatory_space_highlighted_elements view hook
    config_accessor :participatory_space_highlighted_campaigns_limit do
      3
    end

    # Default recurrent contribution
    config_accessor :default_frequency do
      "monthly"
    end

    config_accessor :enabled_payment_methods do
      %w(direct_debit credit_card_external).freeze
    end

    def self.active?
      ActiveRecord::Base.connection.table_exists?("decidim_crowdfundings_campaigns")
    rescue ActiveRecord::NoDatabaseError
      false
    end
  end
end
