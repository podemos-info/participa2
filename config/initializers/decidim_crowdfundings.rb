# frozen_string_literal: true

Decidim::Crowdfundings.configure do |config|
  config.maximum_annual_contribution_amount = 10_000_000
  config.enabled_payment_methods = %w(direct_debit).freeze
end
