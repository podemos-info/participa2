# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Crowdfundings
    describe CampaignsHelper do
      describe "frequency_options" do
        it "returns available frequency options" do
          expect(helper.frequency_options).to eq(
            [
              %w(Punctual punctual),
              %w(Monthly monthly),
              %w(Quarterly quarterly),
              %w(Annual annual)
            ]
          )
        end

        it "returns all the available recurrent frequency options" do
          expect(helper.recurrent_frequency_options).to eq(
            [
              %w(Monthly monthly),
              %w(Quarterly quarterly),
              %w(Annual annual)
            ]
          )
        end
      end

      describe "decidim_number_to_currency" do
        it "formats number using decidim currency" do
          expect(helper.decidim_number_to_currency(100)).to end_with("100.00 #{Decidim.currency_unit}")
        end

        it "fallbacks to 0" do
          expect(helper.decidim_number_to_currency(0)).to end_with("0.00 #{Decidim.currency_unit}")
        end
      end
    end
  end
end
